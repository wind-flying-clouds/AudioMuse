import Combine
import UIKit

final class NextPlayerControlButton: PlayerControlButton {
    override init(playbackController: PlaybackController) {
        super.init(playbackController: playbackController)
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .white
        configuration.contentInsets = .zero
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            pointSize: 20,
            weight: .regular,
        )
        self.configuration = configuration
        tintColor = .white
        setImage(UIImage(systemName: "forward.fill"), for: .normal)
        accessibilityLabel = String(localized: "Next")
    }

    override func didTap() {
        super.didTap()
        playbackController.next()
    }

    override func bindState() {
        playbackController.$snapshot
            .map { $0.currentTrack != nil }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                self?.isEnabled = isEnabled
                self?.alpha = isEnabled ? 1 : 0.1
            }
            .store(in: &controlCancellables)
    }
}
