//
//  TVTransportButton.swift
//  MuseAmpTV
//
//  Focusable button with SF Symbol icon and press animations
//  for tvOS remote interaction.
//

import SnapKit
import UIKit

final class TVTransportButton: UIControl {
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        return view
    }()

    init(
        systemName: String,
        symbolConfig: UIImage.SymbolConfiguration,
        accessibilityLabel: String,
    ) {
        super.init(frame: .zero)
        self.accessibilityLabel = accessibilityLabel
        iconView.image = UIImage(systemName: systemName, withConfiguration: symbolConfig)
        addSubview(iconView)
        alpha = 0.1

        snp.makeConstraints { make in
            make.size.equalTo(TVNowPlayingLayout.transportButtonSize)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        iconView.frame = bounds
    }

    override var canBecomeFocused: Bool {
        true
    }

    override func didUpdateFocus(
        in context: UIFocusUpdateContext,
        with coordinator: UIFocusAnimationCoordinator,
    ) {
        super.didUpdateFocus(in: context, with: coordinator)
        coordinator.addCoordinatedAnimations {
            self.alpha = self.isFocused ? 1.0 : 0.1
        }
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        guard presses.contains(where: { $0.type == .select }) else { return }
        Interface.animate(duration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.alpha = 0.5
        }
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)
        guard presses.contains(where: { $0.type == .select }) else { return }
        sendActions(for: .primaryActionTriggered)
        Interface.animate(duration: 0.15) {
            self.transform = .identity
            self.alpha = self.isFocused ? 1.0 : 0.1
        }
    }

    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesCancelled(presses, with: event)
        Interface.animate(duration: 0.15) {
            self.transform = .identity
            self.alpha = self.isFocused ? 1.0 : 0.1
        }
    }

    func updateImage(systemName: String, symbolConfig: UIImage.SymbolConfiguration) {
        iconView.image = UIImage(systemName: systemName, withConfiguration: symbolConfig)
    }
}
