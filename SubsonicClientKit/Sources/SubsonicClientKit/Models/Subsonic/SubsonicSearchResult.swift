//
//  SubsonicSearchResult.swift
//  SubsonicClientKit
//
//  Created by @Lakr233 on 2026/04/14.
//

import Foundation

struct SubsonicSearchResultPayload: Decodable {
    let searchResult: SubsonicSearchResult?

    private enum CodingKeys: String, CodingKey {
        case searchResult = "searchResult3"
    }
}

struct SubsonicSearchResult: Decodable, Sendable {
    let songs: [SubsonicSong]
    let albums: [SubsonicAlbum]
    let artists: [SubsonicArtist]

    private enum CodingKeys: String, CodingKey {
        case songs = "song"
        case albums = "album"
        case artists = "artist"
    }

    init(
        songs: [SubsonicSong],
        albums: [SubsonicAlbum],
        artists: [SubsonicArtist],
    ) {
        self.songs = songs
        self.albums = albums
        self.artists = artists
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        songs = try container.decodeIfPresent([SubsonicSong].self, forKey: .songs) ?? []
        albums = try container.decodeIfPresent([SubsonicAlbum].self, forKey: .albums) ?? []
        artists = try container.decodeIfPresent([SubsonicArtist].self, forKey: .artists) ?? []
    }
}
