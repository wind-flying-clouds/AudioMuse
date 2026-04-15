import SnapKit
import UIKit

@MainActor
final class NowPlayingRelaxedTransportView: NowPlayingTransportView {
    let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(
            items: [
                String(localized: "Lyrics"),
                String(localized: "Queue"),
            ],
        )
        segmentedControl.selectedSegmentIndex = 0
        let clearImage = UIImage()
        segmentedControl.setBackgroundImage(clearImage, for: .normal, barMetrics: .default)
        segmentedControl.setBackgroundImage(clearImage, for: .selected, barMetrics: .default)
        segmentedControl.setBackgroundImage(clearImage, for: .highlighted, barMetrics: .default)
        segmentedControl.setDividerImage(clearImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        segmentedControl.setDividerImage(clearImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        segmentedControl.setDividerImage(clearImage, forLeftSegmentState: .normal, rightSegmentState: .selected, barMetrics: .default)
        segmentedControl.backgroundColor = .clear
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white.withAlphaComponent(0.4),
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
        ], for: .selected)
        return segmentedControl
    }()

    override init(environment: AppEnvironment) {
        super.init(environment: environment)

        configureLabelStyle(
            titleFont: .systemFont(ofSize: 15, weight: .semibold),
            artistFont: .systemFont(ofSize: 15, weight: .regular),
        )

        let container = UIView()
        container.addSubview(segmentedControl)

        segmentedControl.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 180, height: 32))
            make.top.bottom.equalToSuperview()
        }

        installSupplementaryView(container, spacing: 12)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}
