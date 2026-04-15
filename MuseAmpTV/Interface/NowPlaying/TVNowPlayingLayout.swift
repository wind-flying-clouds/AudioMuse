//
//  TVNowPlayingLayout.swift
//  MuseAmpTV
//
//  Centralised spacing, sizing, and font constants for the tvOS
//  Now Playing page. All spacing values follow an 8/16/32/64 scale.
//

import UIKit

nonisolated enum TVNowPlayingLayout {
    // MARK: - Spacing (8 / 16 / 32 / 64)

    static let spacing8: CGFloat = 8
    static let spacing16: CGFloat = 16
    static let spacing32: CGFloat = 32
    static let spacing64: CGFloat = 64

    // MARK: - Font (left panel: two sizes only)

    static let titleFontSize: CGFloat = 32
    static let bodyFontSize: CGFloat = 24

    // MARK: - Artwork

    static let artworkCornerRadius: CGFloat = 32
    static let placeholderSymbolSize: CGFloat = 120

    // MARK: - Progress

    static let progressHeight: CGFloat = 12
    static let progressCornerRadius: CGFloat = 6

    // MARK: - Transport

    static let transportButtonSize: CGFloat = 48
    static let transportSymbolSize: CGFloat = 32

    // MARK: - Lyrics (right panel)

    static let lyricFontSize: CGFloat = 48
    static let lyricMessageFontSize: CGFloat = 36
    static let lyricTopFadeFraction: CGFloat = 0.2
    static let lyricBottomFadeFraction: CGFloat = 0.28
    static let lyricSpacerHeight: CGFloat = 200
}
