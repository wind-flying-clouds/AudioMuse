import SnapKit
import UIKit

@MainActor
class AmMediaRowView: UIView {
    private let artworkView = MuseAmpImageView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = PlatformInterfacePalette.secondaryText
        label.numberOfLines = 1
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func configure(content: MediaRowContent) {
        titleLabel.attributedText = nil
        titleLabel.text = content.title
        subtitleLabel.attributedText = nil
        subtitleLabel.text = content.subtitle
        subtitleLabel.isHidden = content.subtitle == nil
        artworkView.configure(
            placeholder: content.artwork.placeholderIcon,
            cornerRadius: content.artwork.cornerRadius,
        )
    }

    func setAttributedTitle(_ attributedTitle: NSAttributedString) {
        titleLabel.attributedText = attributedTitle
    }

    func setAttributedSubtitle(_ attributedSubtitle: NSAttributedString?) {
        subtitleLabel.attributedText = attributedSubtitle
        subtitleLabel.isHidden = attributedSubtitle == nil
    }

    func loadArtwork(url: URL?) {
        artworkView.loadImage(url: url)
    }

    func setArtworkImage(_ image: UIImage) {
        artworkView.setImage(image)
    }

    func resetArtwork() {
        artworkView.reset()
    }

    func prepareForReuse() {
        artworkView.reset()
        titleLabel.text = nil
        subtitleLabel.text = nil
        subtitleLabel.isHidden = false
    }

    private func setup() {
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = InterfaceStyle.Spacing.xSmall
        textStack.alignment = .fill

        let row = UIStackView(arrangedSubviews: [artworkView, textStack])
        row.axis = .horizontal
        row.spacing = InterfaceStyle.Spacing.small
        row.alignment = .top

        addSubview(row)

        artworkView.snp.makeConstraints { make in
            make.size.equalTo(44)
        }
        artworkView.setContentCompressionResistancePriority(.required, for: .vertical)
        artworkView.setContentCompressionResistancePriority(.required, for: .horizontal)
        row.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
