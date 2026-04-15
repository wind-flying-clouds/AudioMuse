//
//  SubsonicLyrics.swift
//  SubsonicClientKit
//
//  Created by @Lakr233 on 2026/04/14.
//

import Foundation

struct SubsonicLyricsPayload: Decodable {
    let text: String

    private enum CodingKeys: String, CodingKey {
        case lyrics
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try? container.decode(String.self, forKey: .lyrics) {
            text = value
            return
        }

        if let lyrics = try? container.decode(SubsonicLyrics.self, forKey: .lyrics) {
            text = lyrics.text
            return
        }

        text = ""
    }
}

struct SubsonicLyrics: Decodable, Sendable {
    let text: String

    private enum CodingKeys: String, CodingKey {
        case value
        case lines = "line"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try container.decodeIfPresent(String.self, forKey: .value) {
            text = value
            return
        }

        let lines = try container.decodeIfPresent([SubsonicLyricsLine].self, forKey: .lines) ?? []
        text = lines.map(\.value).joined(separator: "\n")
    }
}

private struct SubsonicLyricsLine: Decodable {
    let value: String

    private enum CodingKeys: String, CodingKey {
        case value
    }
}
