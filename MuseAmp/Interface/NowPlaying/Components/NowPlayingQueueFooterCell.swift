import SnapKit
import UIKit

@MainActor
final class NowPlayingQueueFooterCell: TableBaseCell {
    static let reuseID = "NowPlayingQueueFooterCell"

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.48)
        label.font = UIFontMetrics(forTextStyle: .footnote).scaledFont(
            for: .systemFont(ofSize: 13, weight: .regular),
        )
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(summaryLabel)
        summaryLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func configure(content: AMNowPlayingQueueFooterContent) {
        configure(
            remainingCount: content.remainingCount,
            totalMinutes: content.totalMinutes,
        )
    }

    func configure(remainingCount: Int, totalMinutes: Int) {
        if remainingCount > 0 {
            summaryLabel.text = String(
                localized: "With \(remainingCount) songs left, \(totalMinutes) minutes total",
            )
        } else {
            summaryLabel.text = String(localized: "\(totalMinutes) minutes total")
        }
    }
}
