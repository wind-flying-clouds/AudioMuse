//
//  SubsonicSong.swift
//  SubsonicClientKit
//
//  Created by @Lakr233 on 2026/04/14.
//

import Foundation

struct SubsonicSongPayload: Decodable {
    let song: SubsonicSong?
}

struct SubsonicSong: Decodable, Sendable {
    let id: String
    let title: String
    let album: String?
    let albumId: String?
    let artist: String?
    let artistId: String?
    let coverArt: String?
    let duration: Int?
    let track: Int?
    let discNumber: Int?
    let year: Int?
    let genre: String?
    let suffix: String?
    let contentType: String?
    let size: Int64?

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case album
        case albumId
        case artist
        case artistId
        case coverArt
        case duration
        case track
        case discNumber
        case year
        case genre
        case suffix
        case contentType
        case size
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeLossyString(forKey: .id)
        title = try container.decodeLossyString(forKey: .title)
        album = try container.decodeLossyStringIfPresent(forKey: .album)
        albumId = try container.decodeLossyStringIfPresent(forKey: .albumId)
        artist = try container.decodeLossyStringIfPresent(forKey: .artist)
        artistId = try container.decodeLossyStringIfPresent(forKey: .artistId)
        coverArt = try container.decodeLossyStringIfPresent(forKey: .coverArt)
        duration = try container.decodeLossyIntIfPresent(forKey: .duration)
        track = try container.decodeLossyIntIfPresent(forKey: .track)
        discNumber = try container.decodeLossyIntIfPresent(forKey: .discNumber)
        year = try container.decodeLossyIntIfPresent(forKey: .year)
        genre = try container.decodeLossyStringIfPresent(forKey: .genre)
        suffix = try container.decodeLossyStringIfPresent(forKey: .suffix)
        contentType = try container.decodeLossyStringIfPresent(forKey: .contentType)
        size = try container.decodeLossyInt64IfPresent(forKey: .size)
    }
}
