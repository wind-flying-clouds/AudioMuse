import SnapKit
import UIKit

@MainActor
final class NowPlayingQueueEmptyCell: TableBaseCell {
    static let reuseID = "NowPlayingQueueEmptyCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "Queue is Empty")
        label.textColor = UIColor.white.withAlphaComponent(0.72)
        label.font = UIFontMetrics(forTextStyle: .body).scaledFont(
            for: .systemFont(ofSize: 16, weight: .medium),
        )
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}
