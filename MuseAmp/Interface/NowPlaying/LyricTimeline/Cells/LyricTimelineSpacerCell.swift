import SnapKit
import UIKit

@MainActor
final class LyricTimelineSpacerCell: UITableViewCell {
    private let spacerView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(spacerView)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func configure(height: CGFloat) {
        spacerView.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview().priority(.high)
            make.height.equalTo(height)
            make.width.greaterThanOrEqualTo(10)
        }
    }
}
