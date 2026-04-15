//
//  LyricsReloadService.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/13.
//

@preconcurrency import AVFoundation
import Foundation
import MuseAmpDatabaseKit

final class LyricsReloadService {
    nonisolated struct RebuildAllLyricsIndexResult: Sendable, Equatable {
        let tracksProcessed: Int
        let tracksSucceeded: Int
        let tracksFailed: Int
    }

    private let apiClient: APIClient
    private let lyricsCacheStore: LyricsCacheStore
    private let database: MusicLibraryDatabase
    private let paths: LibraryPaths

    init(
        apiClient: APIClient,
        lyricsCacheStore: LyricsCacheStore,
        database: MusicLibraryDatabase,
        paths: LibraryPaths,
    ) {
        self.apiClient = apiClient
        self.lyricsCacheStore = lyricsCacheStore
        self.database = database
        self.paths = paths
    }

    /// Reloads lyrics for a track: prefers offloading from the downloaded file, falling back to the
    /// remote server. When fetched from the server and the track is downloaded, the new lyrics are
    /// re-embedded into the file on disk. Always persists to the on-disk cache and posts
    /// `.lyricsDidUpdate` on success.
    @discardableResult
    func reloadLyrics(for trackID: String, forceRemoteFetch: Bool = false) async throws -> String {
        let track = database.trackOrNil(byID: trackID)
        let fileURL = track.map { paths.absoluteAudioURL(for: $0.relativePath) }
        let fileExists = fileURL.map { FileManager.default.isReadableFile(atPath: $0.path) } ?? false

        if !forceRemoteFetch,
           fileExists,
           let fileURL,
           let embedded = await extractEmbeddedLyrics(fromFileAt: fileURL),
           !embedded.isEmpty
        {
            try lyricsCacheStore.saveLyrics(embedded, for: trackID)
            postLyricsDidUpdate(trackID: trackID)
            AppLog.info(
                self,
                "reloadLyrics source=embedded trackID=\(trackID) length=\(embedded.count)",
            )
            return embedded
        }

        AppLog.info(self, "reloadLyrics source=network-start trackID=\(trackID)")
        let fetched = try await apiClient.lyrics(id: trackID)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        try lyricsCacheStore.saveLyrics(fetched, for: trackID)

        if fileExists, let fileURL, let track {
            await embedLyricsIfPossible(fetched, into: fileURL, track: track)
        }

        postLyricsDidUpdate(trackID: trackID)
        AppLog.info(
            self,
            "reloadLyrics source=network-success trackID=\(trackID) length=\(fetched.count)",
        )
        return fetched
    }

    func rebuildAllLyricsIndex(
        progressCallback: (@Sendable (_ current: Int, _ total: Int, _ trackTitle: String) -> Void)? = nil,
    ) async throws -> RebuildAllLyricsIndexResult {
        let tracks = try database.allTracks()
            .sorted { lhs, rhs in
                let lhsArtist = lhs.artistName.localizedCaseInsensitiveCompare(rhs.artistName)
                if lhsArtist != .orderedSame {
                    return lhsArtist == .orderedAscending
                }
                let lhsAlbum = lhs.albumTitle.localizedCaseInsensitiveCompare(rhs.albumTitle)
                if lhsAlbum != .orderedSame {
                    return lhsAlbum == .orderedAscending
                }
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }

        AppLog.info(self, "rebuildAllLyricsIndex started total=\(tracks.count)")
        try lyricsCacheStore.removeAllLyrics()

        var tracksSucceeded = 0
        var tracksFailed = 0

        for (index, track) in tracks.enumerated() {
            progressCallback?(index, tracks.count, track.title)
            do {
                _ = try await reloadLyrics(for: track.trackID, forceRemoteFetch: true)
                tracksSucceeded += 1
            } catch {
                tracksFailed += 1
                AppLog.error(
                    self,
                    "rebuildAllLyricsIndex track failed trackID=\(track.trackID) error=\(error.localizedDescription)",
                )
            }
        }

        AppLog.info(
            self,
            "rebuildAllLyricsIndex completed total=\(tracks.count) success=\(tracksSucceeded) failed=\(tracksFailed)",
        )
        return RebuildAllLyricsIndexResult(
            tracksProcessed: tracks.count,
            tracksSucceeded: tracksSucceeded,
            tracksFailed: tracksFailed,
        )
    }

    private func extractEmbeddedLyrics(fromFileAt url: URL) async -> String? {
        let asset = AVURLAsset(url: url)
        guard let items = try? await AVMetadataHelper.collectMetadataItems(from: asset) else {
            return nil
        }
        for item in items {
            let isLyrics = item.identifier == .iTunesMetadataLyrics
                || AVMetadataHelper.matches(item, tokens: ["lyrics", "lyr"])
            guard isLyrics else { continue }
            if let value = try? await item.load(.stringValue)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                !value.isEmpty
            {
                return value
            }
            if let value = try? await item.load(.value) as? String {
                let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    return trimmed
                }
            }
        }
        return nil
    }

    private func embedLyricsIfPossible(
        _ lyrics: String,
        into fileURL: URL,
        track: AudioTrackRecord,
    ) async {
        let info = ExportMetadataProcessor.ExportInfo(
            trackID: track.trackID,
            albumID: track.albumID,
            artworkURL: nil,
            artworkData: nil,
            lyrics: lyrics,
            title: track.title,
            artistName: track.artistName,
            albumName: track.albumTitle,
        )
        do {
            try ExportMetadataProcessor.validateExportInfo(info)
            try await ExportMetadataProcessor.embedExportMetadata(info, into: fileURL)
        } catch {
            AppLog.warning(
                self,
                "reloadLyrics re-embed failed trackID=\(track.trackID) error=\(error.localizedDescription)",
            )
        }
    }

    private func postLyricsDidUpdate(trackID: String) {
        NotificationCenter.default.post(
            name: .lyricsDidUpdate,
            object: nil,
            userInfo: [AppNotificationUserInfoKey.trackIDs: [trackID]],
        )
    }
}
