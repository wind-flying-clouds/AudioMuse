//
//  Extension+String.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/11.
//

import Foundation

extension String {
    nonisolated var sanitizedTrackTitle: String {
        TrackTitleSanitizer.sanitize(self)
    }
}
