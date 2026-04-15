import SnapKit
import UIKit

@MainActor
class AmSongCell: TableBaseCell {
    private nonisolated enum Layout {
        static let defaultRowInsets = InterfaceStyle.Insets.symmetric(
            vertical: 6,
            horizontal: InterfaceStyle.Spacing.small,
        )
    }

    class var reuseID: String {
        String(describing: self)
    }

    private let artworkView: MuseAmpImageView = {
        let view = MuseAmpImageView()
        view.configure(placeholder: "music.note", cornerRadius: 6)
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = PlatformInterfacePalette.secondaryText
        return label
    }()

    private let trailingLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        label.textColor = PlatformInterfacePalette.tertiaryText
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let downloadedIndicator: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "arrow.down.to.line.circle.fill"))
        imageView.tintColor = .tintColor
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    private let nowPlayingBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.tintColor.withAlphaComponent(0.1)
        view.layer.cornerRadius = 4
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()

    private let textStack = UIStackView()
    private let row = UIStackView()

    private var rowInsets = Layout.defaultRowInsets
    private var rowTopConstraint: Constraint?
    private var rowLeftConstraint: Constraint?
    private var rowBottomConstraint: Constraint?
    private var rowRightConstraint: Constraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        contentView.clipsToBounds = true

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)
        textStack.axis = .vertical
        textStack.spacing = InterfaceStyle.Spacing.xSmall

        row.addArrangedSubview(artworkView)
        row.addArrangedSubview(textStack)
        row.addArrangedSubview(trailingLabel)
        row.addArrangedSubview(downloadedIndicator)
        row.axis = .horizontal
        row.spacing = InterfaceStyle.Spacing.small
        row.alignment = .center

        contentView.addSubview(nowPlayingBackgroundView)
        contentView.addSubview(row)

        nowPlayingBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        artworkView.snp.makeConstraints { make in
            make.size.equalTo(44)
        }
        artworkView.setContentCompressionResistancePriority(.required, for: .vertical)
        artworkView.setContentCompressionResistancePriority(.required, for: .horizontal)
        downloadedIndicator.snp.makeConstraints { make in
            make.size.equalTo(18)
        }
        row.snp.makeConstraints { make in
            rowTopConstraint = make.top.equalToSuperview().offset(rowInsets.top).constraint
            rowLeftConstraint = make.leading.equalToSuperview().offset(rowInsets.left).constraint
            rowBottomConstraint = make.bottom.equalToSuperview().inset(rowInsets.bottom).constraint
            rowRightConstraint = make.trailing.equalToSuperview().inset(rowInsets.right).constraint
        }
    }

    func configure(content: SongRowContent) {
        titleLabel.text = content.title
        subtitleLabel.text = content.subtitle
        trailingLabel.text = content.trailingText
        artworkView.configure(
            placeholder: content.artwork.placeholderIcon,
            cornerRadius: content.artwork.cornerRadius,
        )
        artworkView.loadImage(url: content.artworkURL)
        setDownloadedIndicatorVisible(content.showsDownloadedIndicator)
        setTrailingLabelHidden(content.hidesTrailingText)
        applyAppearanceStyle(content.appearanceStyle)
    }

    func setAttributedTitle(_ attributedTitle: NSAttributedString?) {
        titleLabel.attributedText = attributedTitle
    }

    func setAttributedSubtitle(_ attributedSubtitle: NSAttributedString?) {
        subtitleLabel.attributedText = attributedSubtitle
    }

    func loadArtwork(url: URL?) {
        artworkView.loadImage(url: url)
    }

    func setRowInsets(_ insets: UIEdgeInsets) {
        guard rowInsets != insets else {
            return
        }
        rowInsets = insets
        applyRowInsets()
    }

    func setDownloadedIndicatorVisible(_ visible: Bool) {
        downloadedIndicator.isHidden = !visible
    }

    func setNowPlaying(_ isNowPlaying: Bool) {
        nowPlayingBackgroundView.isHidden = !isNowPlaying
    }

    func setTrailingLabelHidden(_ isHidden: Bool) {
        trailingLabel.isHidden = isHidden
    }

    func applyAppearanceStyle(_ style: SongRowContent.AppearanceStyle) {
        switch style {
        case .standard:
            titleLabel.textColor = .label
            subtitleLabel.textColor = PlatformInterfacePalette.secondaryText
            trailingLabel.textColor = PlatformInterfacePalette.tertiaryText
        case .nowPlaying:
            titleLabel.textColor = .white
            subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.78)
            trailingLabel.textColor = UIColor.white.withAlphaComponent(0.62)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        artworkView.reset()
        titleLabel.text = nil
        subtitleLabel.text = nil
        trailingLabel.text = nil
        trailingLabel.isHidden = false
        downloadedIndicator.isHidden = true
        nowPlayingBackgroundView.isHidden = true
        setRowInsets(Layout.defaultRowInsets)
        applyAppearanceStyle(.standard)
    }

    private func applyRowInsets() {
        rowTopConstraint?.update(offset: rowInsets.top)
        rowLeftConstraint?.update(offset: rowInsets.left)
        rowBottomConstraint?.update(inset: rowInsets.bottom)
        rowRightConstraint?.update(inset: rowInsets.right)
    }
}
