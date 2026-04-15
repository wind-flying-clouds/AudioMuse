//
//  SubsonicArtist.swift
//  SubsonicClientKit
//
//  Created by @Lakr233 on 2026/04/14.
//

import Foundation

struct SubsonicArtist: Decodable, Sendable {
    let id: String
    let name: String
    let coverArt: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case coverArt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeLossyString(forKey: .id)
        name = try container.decodeLossyString(forKey: .name)
        coverArt = try container.decodeLossyStringIfPresent(forKey: .coverArt)
    }
}
