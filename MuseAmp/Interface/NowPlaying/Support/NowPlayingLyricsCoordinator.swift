//
//  NowPlayingLyricsCoordinator.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/11.
//

import Combine
import ConfigurableKit
import Foundation
import SubsonicClientKit

@MainActor
final class NowPlayingLyricsCoordinator {
    private let environment: AppEnvironment
    private let logOwner: String
    private let currentTrackID: () -> String?
    private let currentPlaybackTime: () -> TimeInterval
    private let shouldApplyLoadedLyrics: (String) -> Bool
    private let updateLyricsView: (String?, Bool, TimeInterval) -> Void
    private let onLyricsDidReload: () -> Void

    private var lyricsTask: Task<Void, Never>?
    private var lyricsCache: [String: String] = [:]
    private var lyricsRawCache: [String: String] = [:]
    private var lyricsLoadingTrackID: String?
    private var lyricsTransientFailureTrackID: String?
    private nonisolated(unsafe) var lyricsDidUpdateObserver: NSObjectProtocol?

    init(
        environment: AppEnvironment,
        logOwner: String,
        currentTrackID: @escaping () -> String?,
        currentPlaybackTime: @escaping () -> TimeInterval,
        shouldApplyLoadedLyrics: @escaping (String) -> Bool,
        updateLyricsView: @escaping (String?, Bool, TimeInterval) -> Void,
        onLyricsDidReload: @escaping () -> Void = {},
    ) {
        self.environment = environment
        self.logOwner = logOwner
        self.currentTrackID = currentTrackID
        self.currentPlaybackTime = currentPlaybackTime
        self.shouldApplyLoadedLyrics = shouldApplyLoadedLyrics
        self.updateLyricsView = updateLyricsView
        self.onLyricsDidReload = onLyricsDidReload
        observeLyricsDidUpdate()
    }

    deinit {
        lyricsTask?.cancel()
        if let lyricsDidUpdateObserver {
            NotificationCenter.default.removeObserver(lyricsDidUpdateObserver)
        }
    }

    var loadingTrackID: String? {
        lyricsLoadingTrackID
    }

    func lyricsText(for trackID: String) -> String? {
        lyricsCache[trackID]
    }

    func isLoading(trackID: String) -> Bool {
        lyricsLoadingTrackID == trackID
    }

    func bindChineseConvertPreference(storeIn cancellables: inout Set<AnyCancellable>) {
        ConfigurableKit.publisher(
            forKey: AppPreferences.lyricsAutoConvertChineseKey,
            type: Bool.self,
        )
        .dropFirst()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.reprocessAllCachedLyrics()
        }
        .store(in: &cancellables)
    }

    func cancelLoading() {
        lyricsTask?.cancel()
        lyricsTask = nil
        lyricsLoadingTrackID = nil
    }

    func clearDisplayedLyrics() {
        cancelLoading()
        updateLyricsView(nil, false, currentPlaybackTime())
    }

    func clearTransientFailureIfNeeded(for trackID: String?) {
        if trackID != lyricsTransientFailureTrackID {
            lyricsTransientFailureTrackID = nil
        }
    }

    func loadLyrics(for trackID: String) {
        if let lyrics = lyricsCache[trackID] {
            AppLog.info(
                logOwner,
                "loadLyrics refresh source=memory-cache trackID=\(trackID) \(nowPlayingLogTextSummary(lyrics))",
            )
            lyricsLoadingTrackID = nil
            if lyricsTransientFailureTrackID == trackID {
                lyricsTransientFailureTrackID = nil
            }
            updateLyricsView(
                lyrics.isEmpty ? nil : lyrics,
                false,
                currentPlaybackTime(),
            )
            return
        }

        if let storedLyrics = environment.lyricsService.cachedLyrics(for: trackID) {
            AppLog.info(
                logOwner,
                "loadLyrics refresh source=offline-cache trackID=\(trackID) \(nowPlayingLogTextSummary(storedLyrics))",
            )
            lyricsLoadingTrackID = nil
            if lyricsTransientFailureTrackID == trackID {
                lyricsTransientFailureTrackID = nil
            }
            cacheLyrics(storedLyrics, for: trackID)
            let cached = lyricsCache[trackID] ?? storedLyrics
            updateLyricsView(
                cached.isEmpty ? nil : cached,
                false,
                currentPlaybackTime(),
            )
            return
        }

        if lyricsTransientFailureTrackID == trackID {
            AppLog.info(
                logOwner,
                "loadLyrics refresh source=transient-failure trackID=\(trackID)",
            )
            lyricsLoadingTrackID = nil
            updateLyricsView(nil, false, currentPlaybackTime())
            return
        }

        if lyricsLoadingTrackID == trackID {
            AppLog.verbose(
                logOwner,
                "loadLyrics refresh source=in-flight trackID=\(trackID)",
            )
            updateLyricsView(nil, true, currentPlaybackTime())
            return
        }

        if let pendingTrackID = lyricsLoadingTrackID,
           pendingTrackID != trackID
        {
            AppLog.info(
                logOwner,
                "loadLyrics refresh cancel pendingTrackID=\(pendingTrackID) nextTrackID=\(trackID)",
            )
        }

        cancelLoading()
        lyricsLoadingTrackID = trackID
        AppLog.info(logOwner, "loadLyrics refresh source=network-start trackID=\(trackID)")
        updateLyricsView(nil, true, currentPlaybackTime())

        lyricsTask = Task { [weak self] in
            guard let self else { return }
            do {
                let lyrics = try await environment.lyricsService.fetchLyrics(for: trackID)
                guard !Task.isCancelled else { return }
                let normalizedLyrics = lyrics.trimmingCharacters(in: .whitespacesAndNewlines)
                environment.lyricsService.persistLyricsIfDownloaded(normalizedLyrics, for: trackID)

                await MainActor.run { [weak self] in
                    guard let self else { return }
                    lyricsLoadingTrackID = nil
                    if lyricsTransientFailureTrackID == trackID {
                        lyricsTransientFailureTrackID = nil
                    }
                    cacheLyrics(normalizedLyrics, for: trackID)
                    AppLog.info(
                        logOwner,
                        "loadLyrics refresh source=network-success trackID=\(trackID) \(nowPlayingLogTextSummary(normalizedLyrics))",
                    )
                    guard currentTrackID() == trackID,
                          shouldApplyLoadedLyrics(trackID)
                    else {
                        return
                    }
                    let cached = lyricsCache[trackID] ?? normalizedLyrics
                    updateLyricsView(
                        cached.isEmpty ? nil : cached,
                        false,
                        currentPlaybackTime(),
                    )
                }
            } catch {
                guard !Task.isCancelled else { return }
                let shouldCacheUnavailableResult = shouldCacheUnavailableLyricsResult(for: error)
                if shouldCacheUnavailableResult {
                    environment.lyricsService.persistLyricsIfDownloaded("", for: trackID)
                }

                await MainActor.run { [weak self] in
                    guard let self else { return }
                    lyricsLoadingTrackID = nil
                    if shouldCacheUnavailableResult {
                        if lyricsTransientFailureTrackID == trackID {
                            lyricsTransientFailureTrackID = nil
                        }
                        lyricsRawCache[trackID] = ""
                        lyricsCache[trackID] = ""
                    } else {
                        lyricsTransientFailureTrackID = trackID
                    }
                    guard currentTrackID() == trackID,
                          shouldApplyLoadedLyrics(trackID)
                    else {
                        return
                    }
                    updateLyricsView(nil, false, currentPlaybackTime())
                    if shouldCacheUnavailableResult {
                        AppLog.info(logOwner, "loadLyrics refresh source=network-unavailable trackID=\(trackID)")
                    } else {
                        AppLog.error(logOwner, "loadLyrics refresh source=network-failure trackID=\(trackID) error=\(error)")
                    }
                }
            }
        }
    }

    private func processedLyrics(_ text: String) -> String {
        guard !text.isEmpty, AppPreferences.isLyricsAutoConvertChineseEnabled else {
            return text
        }
        return LyricsChineseScriptConverter.convertToSystemScript(text)
    }

    private func cacheLyrics(_ text: String, for trackID: String) {
        lyricsRawCache[trackID] = text
        lyricsCache[trackID] = processedLyrics(text)
    }

    private func observeLyricsDidUpdate() {
        lyricsDidUpdateObserver = NotificationCenter.default.addObserver(
            forName: .lyricsDidUpdate,
            object: nil,
            queue: .main,
        ) { [weak self] notification in
            let trackIDs = (notification.userInfo?[AppNotificationUserInfoKey.trackIDs] as? [String]) ?? []
            MainActor.assumeIsolated {
                self?.handleLyricsDidUpdate(trackIDs: trackIDs)
            }
        }
    }

    private func handleLyricsDidUpdate(trackIDs: [String]) {
        guard !trackIDs.isEmpty else {
            return
        }

        for trackID in trackIDs {
            lyricsCache.removeValue(forKey: trackID)
            lyricsRawCache.removeValue(forKey: trackID)
            if lyricsTransientFailureTrackID == trackID {
                lyricsTransientFailureTrackID = nil
            }
        }

        guard let activeTrackID = currentTrackID(),
              trackIDs.contains(activeTrackID)
        else {
            return
        }

        AppLog.info(
            logOwner,
            "lyricsDidUpdate refresh trackID=\(activeTrackID)",
        )
        loadLyrics(for: activeTrackID)
        onLyricsDidReload()
    }

    private func reprocessAllCachedLyrics() {
        for (trackID, raw) in lyricsRawCache {
            lyricsCache[trackID] = processedLyrics(raw)
        }
        guard let trackID = currentTrackID(),
              let lyrics = lyricsCache[trackID]
        else {
            return
        }
        updateLyricsView(
            lyrics.isEmpty ? nil : lyrics,
            false,
            currentPlaybackTime(),
        )
    }
}

func shouldCacheUnavailableLyricsResult(for error: any Error) -> Bool {
    guard let apiError = error as? APIError else {
        return false
    }

    guard case let .requestFailed(statusCode, _) = apiError else {
        return false
    }

    return statusCode == 404
}
