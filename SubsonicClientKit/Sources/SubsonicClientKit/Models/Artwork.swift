//
//  Artwork.swift
//  SubsonicClientKit
//
//  Created by @Lakr233 on 2026/04/11.
//

import Foundation

public struct Artwork: Decodable, Hashable, Sendable {
    public let width: Int?
    public let height: Int?
    public let url: String?

    public init(width: Int?, height: Int?, url: String?) {
        self.width = width
        self.height = height
        self.url = url
    }

    public static func resolvedURLString(
        from rawURL: String,
        width: Int,
        height: Int,
    ) -> String {
        let resolved = rawURL
            .replacingOccurrences(of: "{w}", with: "\(width)")
            .replacingOccurrences(of: "{h}", with: "\(height)")

        guard var components = URLComponents(string: resolved),
              let queryItems = components.queryItems,
              queryItems.isEmpty == false
        else {
            return resolved
        }

        let filteredItems = queryItems.filter { item in
            guard item.name == "size" else {
                return true
            }

            let value = item.value?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return value != "{w}" && value != "{h}"
        }

        components.queryItems = filteredItems.isEmpty ? nil : filteredItems
        return components.string ?? resolved
    }

    public func imageURL(width: Int = 160, height: Int = 160) -> URL? {
        guard let url, url.isEmpty == false else {
            return nil
        }

        let resolvedURL = Self.resolvedURLString(
            from: url,
            width: width,
            height: height,
        )
        return URL(string: resolvedURL)
    }
}
