import SnapKit
import UIKit

@MainActor
final class NowPlayingQueueTrackCell: TableBaseCell {
    nonisolated enum AccessoryStyle {
        case more
        case reorder
    }

    static let reuseID = "NowPlayingQueueTrackCell"

    private nonisolated enum Layout {
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 4
        static let artworkSize: CGFloat = 48
        static let separatorLeadingInset: CGFloat = 76
    }

    private let artworkView = MuseAmpImageView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private let accessoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.tintColor = .secondaryLabel
        return imageView
    }()

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.separator.withAlphaComponent(0.5)
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        artworkView.configure(placeholder: "music.note", cornerRadius: 4)

        let labelsStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelsStack.axis = .vertical
        labelsStack.alignment = .fill
        labelsStack.spacing = 2

        let rowStack = UIStackView(arrangedSubviews: [artworkView, labelsStack, accessoryImageView])
        rowStack.axis = .horizontal
        rowStack.alignment = .center
        rowStack.spacing = 8

        contentView.addSubview(rowStack)
        contentView.addSubview(separatorView)

        artworkView.snp.makeConstraints { make in
            make.size.equalTo(Layout.artworkSize)
        }
        accessoryImageView.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        rowStack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(Layout.verticalInset)
            make.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }
        separatorView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Layout.separatorLeadingInset)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        artworkView.reset()
        titleLabel.text = nil
        subtitleLabel.text = nil
        accessoryImageView.image = nil
        separatorView.isHidden = false
    }

    func configure(
        content: AMQueueItemContent,
        accessoryStyle: AccessoryStyle,
        hidesSeparator: Bool,
    ) {
        titleLabel.text = content.title
        subtitleLabel.text = content.subtitle
        artworkView.loadImage(url: content.artworkURL)
        separatorView.isHidden = hidesSeparator

        let symbolName: String
        let symbolConfiguration: UIImage.SymbolConfiguration

        switch accessoryStyle {
        case .more:
            symbolName = "ellipsis"
            symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        case .reorder:
            symbolName = "line.3.horizontal"
            symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        }

        accessoryImageView.image = UIImage(
            systemName: symbolName,
            withConfiguration: symbolConfiguration,
        )
    }
}
