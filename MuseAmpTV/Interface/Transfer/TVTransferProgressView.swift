import UIKit

@MainActor
final class TVTransferProgressView: UIStackView {
    // MARK: - Subviews

    private let spinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = false
        indicator.startAnimating()
        return indicator
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = String(localized: "Connecting to device, please wait.")
        return label
    }()

    private let trackInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = String(localized: "Scanning songs")
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        axis = .vertical
        alignment = .center
        spacing = 64
        isUserInteractionEnabled = false

        addArrangedSubview(spinner)
        addArrangedSubview(titleLabel)
        addArrangedSubview(trackInfoLabel)

        setCustomSpacing(16, after: titleLabel)
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError()
    }

    // MARK: - Configure

    func configure(content: AMTVReceivingTracksContent) {
        let title = String(localized: "Receiving playlist from \(content.sourceDeviceName)")
        let trackText = if let currentTrackTitle = content.currentTrackTitle {
            "\(currentTrackTitle)  \(content.receivedTrackCount)/\(content.totalTrackCount)"
        } else {
            "\(content.receivedTrackCount)/\(content.totalTrackCount)"
        }

        titleLabel.text = title
        trackInfoLabel.text = trackText

        isAccessibilityElement = true
        accessibilityTraits = .updatesFrequently
        accessibilityLabel = [
            titleLabel.text ?? "",
            content.currentTrackTitle ?? "",
            "\(content.receivedTrackCount) / \(content.totalTrackCount)",
        ]
        .filter { !$0.isEmpty }
        .joined(separator: ", ")
    }
}
