import Combine
import UIKit

@MainActor
class PlayerControlButton: UIButton {
    let playbackController: PlaybackController
    var controlCancellables = Set<AnyCancellable>()
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    init(playbackController: PlaybackController) {
        self.playbackController = playbackController
        super.init(frame: .zero)
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
        bindState()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func didTap() {
        feedbackGenerator.impactOccurred()
    }

    func bindState() {}
}
