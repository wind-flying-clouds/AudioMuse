import SnapKit
import UIKit

@MainActor
class MediaDetailViewController: UIViewController {
    let tableView: UITableView

    init(tableStyle: UITableView.Style) {
        tableView = UITableView(frame: .zero, style: tableStyle)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func configureDetailTableView(backgroundColor: UIColor = PlatformInterfacePalette.primaryBackground) {
        tableView.separatorStyle = .none
        tableView.backgroundColor = backgroundColor
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
