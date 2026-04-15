import SnapKit
import UIKit

@MainActor
class AmMediaCell: TableBaseCell {
    class var reuseID: String {
        String(describing: self)
    }

    private let mediaRowView = AmMediaRowView()
    private let disclosureImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(
                systemName: "chevron.right",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold),
            ),
        )
        imageView.tintColor = PlatformInterfacePalette.tertiaryText
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(mediaRowView)
        contentView.addSubview(disclosureImageView)

        mediaRowView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(InterfaceStyle.Spacing.xSmall)
            make.leading.equalToSuperview().offset(InterfaceStyle.Spacing.small)
            make.bottom.equalToSuperview().offset(-InterfaceStyle.Spacing.xSmall)
            make.trailing.equalTo(disclosureImageView.snp.leading).offset(-8)
        }
        disclosureImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-InterfaceStyle.Spacing.small)
            make.width.equalTo(10)
        }
    }

    func configure(
        content: MediaRowContent,
        accessory: AccessoryContent = .disclosureIndicator,
    ) {
        mediaRowView.configure(content: content)
        setAccessory(accessory)
    }

    func setAttributedTitle(_ attributedTitle: NSAttributedString) {
        mediaRowView.setAttributedTitle(attributedTitle)
    }

    func setAttributedSubtitle(_ attributedSubtitle: NSAttributedString?) {
        mediaRowView.setAttributedSubtitle(attributedSubtitle)
    }

    func loadArtwork(url: URL?) {
        mediaRowView.loadArtwork(url: url)
    }

    func setArtworkImage(_ image: UIImage) {
        mediaRowView.setArtworkImage(image)
    }

    func resetArtwork() {
        mediaRowView.resetArtwork()
    }

    func setAccessory(_ accessory: AccessoryContent) {
        switch accessory {
        case .none:
            disclosureImageView.isHidden = true
        case .disclosureIndicator:
            disclosureImageView.isHidden = false
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        mediaRowView.prepareForReuse()
        setAccessory(.disclosureIndicator)
    }
}
