//
//  SyncBonjourIdentity.swift
//  MuseAmp
//
//  Created by OpenAI on 2026/04/13.
//

import Foundation

enum SyncBonjourIdentity {
    private static let tokenLength = 6
    private static let maxServiceNameUTF8Bytes = 63

    static func makeToken() -> String {
        let raw = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return String(raw.prefix(tokenLength)).uppercased()
    }

    static func makeAdvertisedServiceName(
        baseName: String,
        token: String,
    ) -> String {
        let separator = "-"
        let normalizedToken = token.uppercased()
        let reservedBytes = separator.lengthOfBytes(using: .utf8)
            + normalizedToken.lengthOfBytes(using: .utf8)
        let availableNameBytes = max(1, maxServiceNameUTF8Bytes - reservedBytes)
        let trimmedBaseName = normalizedDisplayBaseName(baseName)
        let truncatedBaseName = truncateUTF8(trimmedBaseName, maxBytes: availableNameBytes)
        return truncatedBaseName + separator + normalizedToken
    }

    static func makeAdvertisedDeviceName(
        baseName: String,
        token: String,
    ) -> String {
        normalizedDisplayBaseName(baseName) + " [" + token.uppercased() + "]"
    }

    private static func normalizedDisplayBaseName(_ baseName: String) -> String {
        let collapsed = baseName
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        return collapsed.isEmpty ? "Muse Amp Device" : collapsed
    }

    private static func truncateUTF8(
        _ value: String,
        maxBytes: Int,
    ) -> String {
        guard value.lengthOfBytes(using: .utf8) > maxBytes else {
            return value
        }

        var result = ""
        var usedBytes = 0
        for scalar in value.unicodeScalars {
            let scalarString = String(scalar)
            let scalarBytes = scalarString.lengthOfBytes(using: .utf8)
            guard usedBytes + scalarBytes <= maxBytes else {
                break
            }
            result.unicodeScalars.append(scalar)
            usedBytes += scalarBytes
        }
        return result.isEmpty ? "Muse Amp" : result
    }
}
