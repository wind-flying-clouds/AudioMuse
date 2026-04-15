//
//  TVNowPlayingTransportBar.swift
//  MuseAmpTV
//
//  Prev / Play-Pause / Next control row for the tvOS Now Playing page.
//

import UIKit

@MainActor
final class TVNowPlayingTransportBar: UIStackView {
    let previousButton: TVTransportButton
    let playPauseButton: TVTransportButton
    let nextButton: TVTransportButton

    private static let symbolConfig = UIImage.SymbolConfiguration(
        pointSize: TVNowPlayingLayout.transportSymbolSize,
        weight: .bold,
    )

    override init(frame: CGRect) {
        previousButton = TVTransportButton(
            systemName: "backward.fill",
            symbolConfig: Self.symbolConfig,
            accessibilityLabel: String(localized: "Previous"),
        )
        playPauseButton = TVTransportButton(
            systemName: "play.fill",
            symbolConfig: Self.symbolConfig,
            accessibilityLabel: String(localized: "Play"),
        )
        nextButton = TVTransportButton(
            systemName: "forward.fill",
            symbolConfig: Self.symbolConfig,
            accessibilityLabel: String(localized: "Next"),
        )

        super.init(frame: frame)

        axis = .horizontal
        alignment = .center
        distribution = .fill
        spacing = TVNowPlayingLayout.spacing64

        addArrangedSubview(previousButton)
        addArrangedSubview(playPauseButton)
        addArrangedSubview(nextButton)
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError()
    }

    func setIsPlaying(_ isPlaying: Bool) {
        let symbol = isPlaying ? "pause.fill" : "play.fill"
        let label = isPlaying ? String(localized: "Pause") : String(localized: "Play")
        playPauseButton.updateImage(
            systemName: symbol,
            symbolConfig: Self.symbolConfig,
        )
        playPauseButton.accessibilityLabel = label
    }
}
