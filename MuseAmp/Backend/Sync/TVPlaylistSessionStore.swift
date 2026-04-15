//
//  TVPlaylistSessionStore.swift
//  MuseAmp
//
//  Created by OpenAI on 2026/04/12.
//

import Foundation
import MuseAmpDatabaseKit

nonisolated struct TVPlaylistSessionManifest: Codable, Hashable {
    let playlistName: String
    let sessionID: String
    let sourceDeviceName: String
    let orderedTrackIDs: [String]
    let expectedTrackCount: Int
    let expectedUniqueTrackCount: Int
    let createdAt: Date
    let updatedAt: Date

    init(
        playlistName: String,
        sessionID: String,
        sourceDeviceName: String,
        orderedTrackIDs: [String],
        expectedTrackCount: Int,
        expectedUniqueTrackCount: Int,
        createdAt: Date,
        updatedAt: Date,
    ) {
        self.playlistName = playlistName
        self.sessionID = sessionID
        self.sourceDeviceName = sourceDeviceName
        self.orderedTrackIDs = orderedTrackIDs
        self.expectedTrackCount = expectedTrackCount
        self.expectedUniqueTrackCount = expectedUniqueTrackCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(syncSession: SyncPlaylistSession, sourceDeviceName: String) {
        self.init(
            playlistName: syncSession.playlistName,
            sessionID: syncSession.sessionID,
            sourceDeviceName: sourceDeviceName,
            orderedTrackIDs: syncSession.orderedTrackIDs,
            expectedTrackCount: syncSession.expectedTrackCount,
            expectedUniqueTrackCount: syncSession.expectedUniqueTrackCount,
            createdAt: syncSession.createdAt,
            updatedAt: syncSession.updatedAt,
        )
    }

    var uniqueTrackIDs: [String] {
        orderedTrackIDs.orderedUnique()
    }

    func playbackItemIdentifier(forTrackID trackID: String, index: Int) -> String {
        "tv-session|\(sessionID)|\(index)|\(trackID)"
    }
}

nonisolated enum TVPlaylistSessionValidationResult: Equatable {
    case missing
    case valid(TVPlaylistSessionManifest)
    case invalid(String)
}

nonisolated struct TVPlaylistSessionStore {
    let fileURL: URL

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileURL: URL) {
        self.fileURL = fileURL
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func load() -> TVPlaylistSessionManifest? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            AppLog.verbose(self, "load no session manifest at \(fileURL.lastPathComponent)")
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let manifest = try decoder.decode(TVPlaylistSessionManifest.self, from: data)
            AppLog.info(
                self,
                "load restored session id=\(manifest.sessionID) playlist='\(sanitizedLogText(manifest.playlistName))' expected=\(manifest.expectedTrackCount)",
            )
            return manifest
        } catch {
            AppLog.error(self, "load failed error=\(error)")
            return nil
        }
    }

    func save(_ manifest: TVPlaylistSessionManifest) {
        do {
            let data = try encoder.encode(manifest)
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true,
                attributes: nil,
            )
            try data.write(to: fileURL, options: .atomic)
            AppLog.info(
                self,
                "save session id=\(manifest.sessionID) playlist='\(sanitizedLogText(manifest.playlistName))' expected=\(manifest.expectedTrackCount)",
            )
        } catch {
            AppLog.error(self, "save failed error=\(error)")
        }
    }

    func clear() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }

        do {
            try FileManager.default.removeItem(at: fileURL)
            AppLog.info(self, "clear removed session manifest")
        } catch {
            AppLog.error(self, "clear failed error=\(error)")
        }
    }

    func validate(
        database: MusicLibraryDatabase,
        paths: LibraryPaths,
    ) -> TVPlaylistSessionValidationResult {
        guard let manifest = load() else {
            return .missing
        }

        guard manifest.expectedTrackCount > 0,
              manifest.expectedUniqueTrackCount > 0
        else {
            AppLog.error(self, "validate invalid expected counts id=\(manifest.sessionID)")
            return .invalid(String(localized: "The transferred playlist data on Apple TV is incomplete. Send it again from iPhone."))
        }

        guard manifest.orderedTrackIDs.count == manifest.expectedTrackCount else {
            AppLog.error(
                self,
                "validate ordered count mismatch id=\(manifest.sessionID) expected=\(manifest.expectedTrackCount) actual=\(manifest.orderedTrackIDs.count)",
            )
            return .invalid(String(localized: "The transferred playlist data on Apple TV is incomplete. Send it again from iPhone."))
        }

        let uniqueTrackIDs = manifest.uniqueTrackIDs
        guard uniqueTrackIDs.count == manifest.expectedUniqueTrackCount else {
            AppLog.error(
                self,
                "validate unique count mismatch id=\(manifest.sessionID) expected=\(manifest.expectedUniqueTrackCount) actual=\(uniqueTrackIDs.count)",
            )
            return .invalid(String(localized: "The transferred playlist data on Apple TV is incomplete. Send it again from iPhone."))
        }

        let storedTracks: [AudioTrackRecord]
        do {
            storedTracks = try database.allTracks()
        } catch {
            AppLog.error(self, "validate failed to read tracks error=\(error)")
            return .invalid(String(localized: "The transferred playlist data on Apple TV is unavailable. Send it again from iPhone."))
        }

        guard storedTracks.count == manifest.expectedUniqueTrackCount else {
            AppLog.warning(
                self,
                "validate track count mismatch id=\(manifest.sessionID) expected=\(manifest.expectedUniqueTrackCount) actual=\(storedTracks.count)",
            )
            return .invalid(String(localized: "Apple TV cleaned part of the transferred playlist. Send it again from iPhone."))
        }

        let tracksByID = Dictionary(uniqueKeysWithValues: storedTracks.map { ($0.trackID, $0) })
        for trackID in uniqueTrackIDs {
            guard let track = tracksByID[trackID] else {
                AppLog.warning(self, "validate missing database track id=\(manifest.sessionID) trackID=\(trackID)")
                return .invalid(String(localized: "Apple TV cleaned part of the transferred playlist. Send it again from iPhone."))
            }

            let fileURL = paths.absoluteAudioURL(for: track.relativePath)
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                AppLog.warning(
                    self,
                    "validate missing audio file id=\(manifest.sessionID) trackID=\(trackID) path=\(fileURL.lastPathComponent)",
                )
                return .invalid(String(localized: "Apple TV cleaned part of the transferred playlist. Send it again from iPhone."))
            }
        }

        return .valid(manifest)
    }
}

private nonisolated extension Array where Element: Hashable {
    func orderedUnique() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
