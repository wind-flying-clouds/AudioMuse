//
//  SubsonicAlbum.swift
//  SubsonicClientKit
//
//  Created by @Lakr233 on 2026/04/14.
//

import Foundation

struct SubsonicAlbumPayload: Decodable {
    let album: SubsonicAlbum?
}

struct SubsonicAlbum: Decodable, Sendable {
    let id: String
    let name: String
    let artist: String?
    let artistId: String?
    let coverArt: String?
    let songCount: Int?
    let year: Int?
    let genre: String?
    let songs: [SubsonicSong]

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case artist
        case artistId
        case coverArt
        case songCount
        case year
        case genre
        case songs = "song"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeLossyString(forKey: .id)
        name = try container.decodeLossyString(forKey: .name)
        artist = try container.decodeLossyStringIfPresent(forKey: .artist)
        artistId = try container.decodeLossyStringIfPresent(forKey: .artistId)
        coverArt = try container.decodeLossyStringIfPresent(forKey: .coverArt)
        songCount = try container.decodeLossyIntIfPresent(forKey: .songCount)
        year = try container.decodeLossyIntIfPresent(forKey: .year)
        genre = try container.decodeLossyStringIfPresent(forKey: .genre)
        songs = try container.decodeIfPresent([SubsonicSong].self, forKey: .songs) ?? []
    }
}
