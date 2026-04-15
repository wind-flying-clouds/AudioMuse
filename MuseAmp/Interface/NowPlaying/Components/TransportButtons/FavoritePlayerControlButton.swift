import Combine
import UIKit

final class FavoritePlayerControlButton: PlayerControlButton {
    override init(playbackController: PlaybackController) {
        super.init(playbackController: playbackController)
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .white
        configuration.contentInsets = .zero
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            pointSize: 16,
            weight: .regular,
        )
        self.configuration = configuration
        tintColor = .white
        setImage(UIImage(systemName: "heart"), for: .normal)
        accessibilityLabel = String(localized: "Favorite")
    }

    override func didTap() {
        super.didTap()
        _ = playbackController.toggleLikedCurrentTrack()
    }

    override func bindState() {
        playbackController.$snapshot
            .map { ($0.currentTrack != nil, $0.isCurrentTrackLiked) }
            .removeDuplicates { $0 == $1 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasTrack, isLiked in
                self?.isEnabled = hasTrack
                self?.alpha = hasTrack ? 1 : 0.1
                let symbol = isLiked ? "heart.fill" : "heart"
                self?.setImage(UIImage(systemName: symbol), for: .normal)
            }
            .store(in: &controlCancellables)
    }
}
