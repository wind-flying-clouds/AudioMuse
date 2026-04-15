//
//  SubsonicResponse.swift
//  SubsonicClientKit
//
//  Created by @Lakr233 on 2026/04/14.
//

import Foundation

struct SubsonicResponse<Payload: Decodable>: Decodable {
    let payload: Payload?
    let status: String
    let error: SubsonicError?

    private enum RootKeys: String, CodingKey {
        case response = "subsonic-response"
    }

    private enum ResponseKeys: String, CodingKey {
        case status
        case error
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        let nestedDecoder = try container.superDecoder(forKey: .response)
        let responseContainer = try nestedDecoder.container(keyedBy: ResponseKeys.self)
        status = try responseContainer.decode(String.self, forKey: .status)
        error = try responseContainer.decodeIfPresent(SubsonicError.self, forKey: .error)
        payload = try Payload(from: nestedDecoder)
    }
}

struct SubsonicError: Decodable, Sendable {
    let code: Int?
    let message: String?
}
