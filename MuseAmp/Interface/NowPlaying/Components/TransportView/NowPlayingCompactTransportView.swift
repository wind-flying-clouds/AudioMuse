import SnapKit
import UIKit

@MainActor
final class NowPlayingCompactTransportView: NowPlayingTransportView {
    private let currentLyricLabel: AnimatedTextLabel = {
        let label = AnimatedTextLabel()
        label.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(
            for: .systemFont(ofSize: 13, weight: .medium),
        )
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.clipsToBounds = false
        label.isUserInteractionEnabled = false
        return label
    }()

    private let lyricTapButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.tintColor = .clear
        button.accessibilityLabel = String(localized: "Current Lyric")
        button.accessibilityHint = String(localized: "Opens the lyrics page")
        return button
    }()

    var onLyricTapped: () -> Void = {}

    private let lyricContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()

    let auxiliaryContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let auxiliaryStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }()

    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .white
        configuration.contentInsets = .zero
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            pointSize: 16,
            weight: .regular,
        )
        button.configuration = configuration
        button.tintColor = .white
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.showsMenuAsPrimaryAction = true
        button.accessibilityLabel = String(localized: "More")
        return button
    }()

    override init(environment: AppEnvironment) {
        super.init(environment: environment)

        let (_, routePickerContainer) = detachAuxiliaryButtons()

        lyricContainer.addSubview(currentLyricLabel)
        lyricContainer.addSubview(lyricTapButton)

        currentLyricLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        lyricTapButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        lyricTapButton.addTarget(self, action: #selector(lyricTapButtonTapped), for: .touchUpInside)

        installSupplementaryView(lyricContainer)

        auxiliaryStack.addArrangedSubview(routePickerContainer)
        auxiliaryStack.addArrangedSubview(moreButton)

        moreButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
        }

        auxiliaryContainerView.addSubview(auxiliaryStack)
        auxiliaryStack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(48)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func setAnimationsSuspended(_ suspended: Bool) {
        super.setAnimationsSuspended(suspended)
        currentLyricLabel.disablesAnimations = suspended
    }

    func updateCurrentLyricLine(_ line: String?) {
        let hasLine = line?.isEmpty == false
        currentLyricLabel.text = line
        lyricContainer.isHidden = !hasLine
        Interface.smoothSpringAnimate {
            self.layoutAnimationContainerView().layoutIfNeeded()
        }
    }

    override func setSongMenu(_ menu: UIMenu?) {
        super.setSongMenu(menu)
        moreButton.menu = menu
    }

    @objc
    private func lyricTapButtonTapped() {
        onLyricTapped()
    }
}
