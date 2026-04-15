//
//  TVNowPlayingLyricsCoordinator.swift
//  MuseAmpTV
//
//  Slim lyrics loader for the tvOS Now Playing page. Ported from
//  MuseAmp/Interface/NowPlaying/Support/NowPlayingLyricsCoordinator.swift
//  with AppEnvironment / ConfigurableKit / Chinese-conversion plumbing removed.
//

import Foundation

@MainActor
final class TVNowPlayingLyricsCoordinator {
    private let lyricsService: LyricsService
    private let currentPlaybackTime: () -> TimeInterval
    private let shouldApplyLoadedLyrics: (String) -> Bool
    private let updateLyricsView: (String?, Bool, TimeInterval) -> Void

    private var lyricsTask: Task<Void, Never>?
    private var lyricsCache: [String: String] = [:]
    private var lyricsLoadingTrackID: String?

    init(
        lyricsService: LyricsService,
        currentPlaybackTime: @escaping () -> TimeInterval,
        shouldApplyLoadedLyrics: @escaping (String) -> Bool,
        updateLyricsView: @escaping (String?, Bool, TimeInterval) -> Void,
    ) {
        self.lyricsService = lyricsService
        self.currentPlaybackTime = currentPlaybackTime
        self.shouldApplyLoadedLyrics = shouldApplyLoadedLyrics
        self.updateLyricsView = updateLyricsView
    }

    deinit {
        lyricsTask?.cancel()
    }

    func clearDisplayedLyrics() {
        lyricsTask?.cancel()
        lyricsTask = nil
        lyricsLoadingTrackID = nil
        updateLyricsView(nil, false, currentPlaybackTime())
    }

    func loadLyrics(for trackID: String) {
        if let lyrics = lyricsCache[trackID] {
            lyricsLoadingTrackID = nil
            updateLyricsView(nil, true, currentPlaybackTime())
            lyricsTask = Task { @MainActor [weak self] in
                guard let self else { return }
                guard !Task.isCancelled else { return }
                updateLyricsView(
                    lyrics.isEmpty ? nil : lyrics,
                    false,
                    currentPlaybackTime(),
                )
            }
            return
        }

        if let storedLyrics = lyricsService.cachedLyrics(for: trackID) {
            lyricsLoadingTrackID = nil
            lyricsCache[trackID] = storedLyrics
            updateLyricsView(nil, true, currentPlaybackTime())
            lyricsTask = Task { @MainActor [weak self] in
                guard let self else { return }
                guard !Task.isCancelled else { return }
                updateLyricsView(
                    storedLyrics.isEmpty ? nil : storedLyrics,
                    false,
                    currentPlaybackTime(),
                )
            }
            return
        }

        if lyricsLoadingTrackID == trackID {
            updateLyricsView(nil, true, currentPlaybackTime())
            return
        }

        lyricsTask?.cancel()
        lyricsLoadingTrackID = trackID
        updateLyricsView(nil, true, currentPlaybackTime())

        lyricsTask = Task { [weak self] in
            guard let self else { return }
            do {
                let lyrics = try await lyricsService.fetchLyrics(for: trackID)
                guard !Task.isCancelled else { return }
                let normalized = lyrics.trimmingCharacters(in: .whitespacesAndNewlines)
                lyricsService.persistLyricsIfDownloaded(normalized, for: trackID)

                await MainActor.run { [weak self] in
                    guard let self else { return }
                    lyricsLoadingTrackID = nil
                    lyricsCache[trackID] = normalized
                    guard shouldApplyLoadedLyrics(trackID) else { return }
                    updateLyricsView(
                        normalized.isEmpty ? nil : normalized,
                        false,
                        currentPlaybackTime(),
                    )
                    AppLog.info(self, "loadLyrics success trackID=\(trackID) length=\(normalized.count)")
                }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    lyricsLoadingTrackID = nil
                    guard shouldApplyLoadedLyrics(trackID) else { return }
                    updateLyricsView(nil, false, currentPlaybackTime())
                    AppLog.error(self, "loadLyrics failed trackID=\(trackID) error=\(error)")
                }
            }
        }
    }
}
