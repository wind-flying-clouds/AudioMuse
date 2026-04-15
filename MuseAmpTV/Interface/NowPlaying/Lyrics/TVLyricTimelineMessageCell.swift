import SnapKit
import UIKit

@MainActor
final class TVLyricTimelineMessageCell: UITableViewCell {
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.white.withAlphaComponent(0.72)
        label.font = UIFontMetrics(forTextStyle: .title3).scaledFont(
            for: .systemFont(ofSize: TVNowPlayingLayout.lyricMessageFontSize, weight: .medium),
        )
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        isUserInteractionEnabled = false

        contentView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(TVNowPlayingLayout.spacing64)
            make.trailing.lessThanOrEqualToSuperview().offset(-TVNowPlayingLayout.spacing64)
            make.top.greaterThanOrEqualToSuperview().offset(TVNowPlayingLayout.spacing16)
            make.bottom.lessThanOrEqualToSuperview().offset(-TVNowPlayingLayout.spacing16)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = nil
    }

    func configure(text: String) {
        messageLabel.text = text
    }
}
