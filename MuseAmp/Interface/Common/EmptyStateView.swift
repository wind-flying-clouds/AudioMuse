import SnapKit
import UIKit

@MainActor
class EmptyStateView: UIView {
    private let iconView: UIImageView
    private let titleLabel: UILabel
    private let subtitleLabel: UILabel

    init(icon: String, title: String, subtitle: String) {
        iconView = UIImageView(image: UIImage(systemName: icon))
        titleLabel = UILabel()
        subtitleLabel = UILabel()

        super.init(frame: .zero)

        iconView.tintColor = PlatformInterfacePalette.quaternaryText
        iconView.contentMode = .scaleAspectFit

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = PlatformInterfacePalette.secondaryText
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        subtitleLabel.text = subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = PlatformInterfacePalette.tertiaryText
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = InterfaceStyle.Spacing.xSmall
        stack.alignment = .center
        stack.setCustomSpacing(InterfaceStyle.Spacing.small, after: iconView)

        addSubview(stack)

        iconView.snp.makeConstraints { make in
            make.size.equalTo(56)
        }

        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}
