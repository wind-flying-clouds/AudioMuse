import SnapKit
import UIKit

@MainActor
final class DetailFooterCell: TableBaseCell {
    static let reuseID = "DetailFooterCell"

    private let infoLabel = UILabel()
    private let badgeStack = UIStackView()
    private let losslessBadge = makeAudioTraitBadge(
        text: String(localized: "Lossless"),
        icon: "waveform",
    )
    private let atmosBadge = makeAudioTraitBadge(
        text: String(localized: "Dolby Atmos"),
        icon: "hifispeaker.2.fill",
    )
    private let spatialBadge = makeAudioTraitBadge(
        text: String(localized: "Spatial"),
        icon: "ear.fill",
    )

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        infoLabel.font = .preferredFont(forTextStyle: .footnote)
        infoLabel.textColor = PlatformInterfacePalette.secondaryText
        infoLabel.numberOfLines = 0

        badgeStack.axis = .horizontal
        badgeStack.spacing = 6
        badgeStack.alignment = .center
        badgeStack.isHidden = true

        badgeStack.addArrangedSubview(losslessBadge)
        badgeStack.addArrangedSubview(atmosBadge)
        badgeStack.addArrangedSubview(spatialBadge)
        losslessBadge.isHidden = true
        atmosBadge.isHidden = true
        spatialBadge.isHidden = true

        contentView.addSubview(infoLabel)
        contentView.addSubview(badgeStack)

        infoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(InterfaceStyle.Spacing.medium)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        badgeStack.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(InterfaceStyle.Spacing.small)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-InterfaceStyle.Spacing.large)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func configure(text: String?, audioTraits: [String] = []) {
        infoLabel.text = text
        configureBadges(audioTraits: audioTraits)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        infoLabel.text = nil
        losslessBadge.isHidden = true
        atmosBadge.isHidden = true
        spatialBadge.isHidden = true
        badgeStack.isHidden = true
    }

    private func configureBadges(audioTraits traits: [String]) {
        let showLossless = traits.contains("lossless")
        let showAtmos = traits.contains("atmos")
        let showSpatial = traits.contains("spatial") && !traits.contains("atmos")
        let showAny = showLossless || showAtmos || showSpatial

        losslessBadge.isHidden = !showLossless
        atmosBadge.isHidden = !showAtmos
        spatialBadge.isHidden = !showSpatial
        badgeStack.isHidden = !showAny
    }
}

@MainActor
private func makeAudioTraitBadge(text: String, icon: String) -> UIView {
    let imageView = UIImageView(image: UIImage(systemName: icon))
    imageView.tintColor = .tintColor
    imageView.contentMode = .scaleAspectFit

    let label = UILabel()
    label.text = text
    label.font = .systemFont(ofSize: 11, weight: .semibold)
    label.textColor = .tintColor

    let stack = UIStackView(arrangedSubviews: [imageView, label])
    stack.axis = .horizontal
    stack.spacing = 3
    stack.alignment = .center
    stack.layoutMargins = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
    stack.isLayoutMarginsRelativeArrangement = true
    stack.backgroundColor = UIColor.tintColor.withAlphaComponent(0.1)
    stack.layer.cornerRadius = 10
    stack.clipsToBounds = true

    imageView.snp.makeConstraints { make in
        make.size.equalTo(12)
    }

    return stack
}
