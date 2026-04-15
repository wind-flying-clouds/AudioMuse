import UIKit

@MainActor
class TableBaseCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = PlatformInterfacePalette.primaryBackground
        contentView.backgroundColor = PlatformInterfacePalette.primaryBackground
        selectionStyle = .none
        selectedBackgroundView = UIView()
        clipsToBounds = true
        contentView.clipsToBounds = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        selectedBackgroundView = UIView()
    }

    override func setSelected(_ selected: Bool, animated _: Bool) {
        super.setSelected(selected, animated: false)
        selectedBackgroundView?.isHidden = true
    }

    override func setHighlighted(_ highlighted: Bool, animated _: Bool) {
        super.setHighlighted(highlighted, animated: false)
        selectedBackgroundView?.isHidden = true
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        selectionStyle = editing ? .default : .none
    }
}
