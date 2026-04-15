import SnapKit
import UIKit

@MainActor
final class NowPlayingQueueHeaderCell: TableBaseCell {
    static let reuseID = "NowPlayingQueueHeaderCell"

    private nonisolated enum Layout {
        static let controlSize: CGFloat = 40
        static let actionsWidth: CGFloat = 92
        static let horizontalInset: CGFloat = 20
    }

    private enum Palette {
        static let activeForeground = UIColor.white
        static let inactiveForeground = UIColor.white.withAlphaComponent(0.58)
        static let activeBackground = UIColor.white.withAlphaComponent(0.18)
        static let inactiveBackground = UIColor.white.withAlphaComponent(0.05)
        static let activeBorder = UIColor.white.withAlphaComponent(0.32)
        static let inactiveBorder = UIColor.white.withAlphaComponent(0.12)
    }

    #if os(iOS)
        private let buttonFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    #endif
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFontMetrics(forTextStyle: .title2).scaledFont(
            for: .systemFont(ofSize: 24, weight: .bold),
        )
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor.white.withAlphaComponent(0.92)
        return label
    }()

    private let shuffleButton = UIButton(type: .system)
    private let repeatButton = UIButton(type: .system)
    private lazy var actionsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [shuffleButton, repeatButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()

    private var actionsWidthConstraint: Constraint?
    private var onShuffleTap: () -> Void = {}
    private var onRepeatTap: () -> Void = {}
    private var isShuffleFeedbackActive = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: Layout.horizontalInset,
            bottom: 0,
            trailing: Layout.horizontalInset,
        )

        contentView.addSubview(titleLabel)
        contentView.addSubview(actionsStack)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView.layoutMarginsGuide.snp.leading)
            make.centerY.equalTo(contentView)
            make.height.equalTo(Layout.controlSize)
            make.trailing.lessThanOrEqualTo(actionsStack.snp.leading).offset(-12)
        }

        actionsStack.snp.makeConstraints { make in
            make.trailing.equalTo(contentView.layoutMarginsGuide.snp.trailing)
            make.centerY.equalTo(contentView)
            make.height.equalTo(Layout.controlSize)
            actionsWidthConstraint = make.width.equalTo(Layout.actionsWidth).constraint
        }

        for (tag, button) in [shuffleButton, repeatButton].enumerated() {
            button.tag = tag + 1
            button.snp.makeConstraints { make in
                make.size.equalTo(Layout.controlSize)
            }
            button.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        onShuffleTap = {}
        onRepeatTap = {}
        isShuffleFeedbackActive = false
        actionsStack.isHidden = true
        actionsWidthConstraint?.update(offset: 0)
        shuffleButton.alpha = 1
    }

    func configure(
        content: AMNowPlayingQueueHeaderContent,
        onShuffleTap: @escaping () -> Void = {},
        onRepeatTap: @escaping () -> Void = {},
    ) {
        switch content {
        case let .title(title):
            titleLabel.text = title
            self.onShuffleTap = {}
            self.onRepeatTap = {}
            isShuffleFeedbackActive = false
            actionsStack.isHidden = true
            actionsWidthConstraint?.update(offset: 0)
        case let .controls(title, repeatMode, isShuffleFeedbackActive, isShuffleEnabled):
            titleLabel.text = title
            self.onShuffleTap = onShuffleTap
            self.onRepeatTap = onRepeatTap
            actionsStack.isHidden = false
            actionsWidthConstraint?.update(offset: Layout.actionsWidth)

            let repeatSymbol = switch repeatMode {
            case .off, .queue:
                "repeat"
            case .track:
                "repeat.1"
            }

            shuffleButton.isEnabled = isShuffleEnabled

            let shouldAnimateShuffleFeedback = self.isShuffleFeedbackActive == false
                && isShuffleFeedbackActive
            self.isShuffleFeedbackActive = isShuffleFeedbackActive

            applyConfiguration(
                to: shuffleButton,
                symbolName: "shuffle",
                isActive: isShuffleFeedbackActive && isShuffleEnabled,
            )
            applyConfiguration(
                to: repeatButton,
                symbolName: repeatSymbol,
                isActive: repeatMode != .off,
            )

            guard shouldAnimateShuffleFeedback else {
                return
            }
            animateShuffleFeedback()
        }
    }

    @objc private func handleTap(_ sender: UIButton) {
        #if os(iOS)
            buttonFeedbackGenerator.impactOccurred()
        #endif
        switch sender.tag {
        case 1:
            onShuffleTap()
        case 2:
            onRepeatTap()
        default:
            break
        }
    }

    private func applyConfiguration(
        to button: UIButton,
        symbolName: String,
        isActive: Bool,
    ) {
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = isActive ? Palette.activeForeground : Palette.inactiveForeground
        configuration.image = UIImage(
            systemName: symbolName,
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: isActive ? 16 : 15,
                weight: isActive ? .bold : .semibold,
            ),
        )
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        configuration.background.cornerRadius = 12
        configuration.background.backgroundColor = isActive
            ? Palette.activeBackground
            : Palette.inactiveBackground
        configuration.background.strokeColor = isActive
            ? Palette.activeBorder
            : Palette.inactiveBorder
        configuration.background.strokeWidth = isActive ? 1.2 : 1
        button.configuration = configuration
    }

    private func animateShuffleFeedback() {
        guard window != nil else {
            return
        }

        shuffleButton.layer.removeAnimation(forKey: "queueShuffleFade")
        shuffleButton.alpha = 1

        Interface.keyframeAnimate(duration: 0.26) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.shuffleButton.alpha = 0.35
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                self.shuffleButton.alpha = 1
            }
        }
    }
}
