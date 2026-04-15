//
//  Playlist.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/11.
//

import Foundation
import MuseAmpDatabaseKit

nonisolated extension MuseAmpDatabaseKit.Playlist {
    static let likedSongsPlaylistID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!

    var isLikedSongsPlaylist: Bool {
        id == Self.likedSongsPlaylistID
    }

    var songs: [PlaylistEntry] {
        get { entries }
        set { entries = newValue }
    }
}

nonisolated enum LikedToggleResult: Equatable {
    case liked
    case unliked
    case playlistUnavailable
}
