//
//  SyncPlaylistTransferPlan.swift
//  MuseAmp
//
//  Created by OpenAI on 2026/04/12.
//

import Foundation
import MuseAmpDatabaseKit

nonisolated struct SyncPlaylistTransferPlan: Equatable {
    let session: SyncPlaylistSession
    let transferableTracks: [AudioTrackRecord]
    let skippedTrackIDs: [String]

    var hasTransferableTracks: Bool {
        !transferableTracks.isEmpty
    }

    init(transferableTracks: [AudioTrackRecord], totalTrackCount _: Int) {
        session = SyncPlaylistSession(
            playlistName: String(localized: "Apple TV Session"),
            orderedTrackIDs: transferableTracks.map(\.trackID),
        )
        self.transferableTracks = transferableTracks
        skippedTrackIDs = []
    }

    init?(playlist: Playlist, database: MusicLibraryDatabase, paths: LibraryPaths) {
        guard !playlist.songs.isEmpty else {
            return nil
        }

        var transferableTracks: [AudioTrackRecord] = []
        var skippedTrackIDs: [String] = []
        var orderedTrackIDs: [String] = []
        var transferredTrackIDs = Set<String>()

        for entry in playlist.songs {
            guard let track = database.trackOrNil(byID: entry.trackID) else {
                skippedTrackIDs.append(entry.trackID)
                continue
            }

            let fileURL = paths.absoluteAudioURL(for: track.relativePath)
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                skippedTrackIDs.append(entry.trackID)
                continue
            }

            orderedTrackIDs.append(entry.trackID)
            if transferredTrackIDs.insert(entry.trackID).inserted {
                transferableTracks.append(track)
            }
        }

        guard !orderedTrackIDs.isEmpty else {
            return nil
        }

        session = SyncPlaylistSession(
            playlistName: playlist.name,
            orderedTrackIDs: orderedTrackIDs,
        )
        self.transferableTracks = transferableTracks
        self.skippedTrackIDs = skippedTrackIDs
    }
}
