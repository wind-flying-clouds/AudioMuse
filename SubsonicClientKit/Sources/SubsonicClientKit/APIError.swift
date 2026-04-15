//
//  APIError.swift
//  SubsonicClientKit
//
//  Created by @Lakr233 on 2026/04/11.
//

import Foundation

public enum APIError: LocalizedError, Sendable {
    case invalidRequest
    case invalidResponse
    case requestFailed(statusCode: Int, serverMessage: String?)
    case subsonicRequestFailed(code: Int?, message: String)
    case decodingFailed(message: String)
    case transportFailed(message: String)

    public var errorDescription: String? {
        switch self {
        case .invalidRequest:
            String(localized: "The request could not be created.", bundle: .module)
        case .invalidResponse:
            String(localized: "The server returned an invalid response.", bundle: .module)
        case let .requestFailed(statusCode, serverMessage):
            if let serverMessage, !serverMessage.isEmpty {
                serverMessage
            } else {
                String(
                    format: String(localized: "The server returned HTTP %ld.", bundle: .module),
                    locale: .current,
                    statusCode,
                )
            }
        case let .subsonicRequestFailed(code, message):
            if let code {
                String(
                    format: String(localized: "Subsonic error %ld: %@", bundle: .module),
                    locale: .current,
                    code,
                    message,
                )
            } else {
                message
            }
        case let .decodingFailed(message):
            message
        case let .transportFailed(message):
            message
        }
    }
}
