import Combine
import UIKit

final class PlayPausePlayerControlButton: PlayerControlButton {
    override init(playbackController: PlaybackController) {
        super.init(playbackController: playbackController)
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .white
        configuration.contentInsets = .zero
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            pointSize: 30,
            weight: .regular,
        )
        self.configuration = configuration
        tintColor = .white
        setImage(UIImage(systemName: "pause.fill"), for: .normal)
        accessibilityLabel = String(localized: "Play Pause")
    }

    override func didTap() {
        super.didTap()
        playbackController.togglePlayPause()
    }

    override func bindState() {
        playbackController.$snapshot
            .map { NowPlayingContentMapper.isPlaying(for: $0.state) }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                let symbol = isPlaying ? "pause.fill" : "play.fill"
                self?.setImage(UIImage(systemName: symbol), for: .normal)
            }
            .store(in: &controlCancellables)
    }
}
