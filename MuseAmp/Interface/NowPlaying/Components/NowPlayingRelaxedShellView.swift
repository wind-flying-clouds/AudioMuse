import SnapKit
import UIKit

enum NowPlayingRelaxedPanel: Equatable {
    case lyrics
    case queue
}

@MainActor
class NowPlayingRelaxedShellView: UIView {
    let leftContentView: UIView
    let lyricsPanelView: UIView
    let queuePanelView: UIView

    private(set) var currentRightPanel: NowPlayingRelaxedPanel = .lyrics

    private let contentSafeAreaView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()

    private let leftPanelView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()

    private let rightPanelView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = false
        return view
    }()

    private let rightPanelContentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = false
        return view
    }()

    init(
        leftContentView: UIView,
        lyricsPanelView: UIView,
        queuePanelView: UIView,
    ) {
        self.leftContentView = leftContentView
        self.lyricsPanelView = lyricsPanelView
        self.queuePanelView = queuePanelView
        super.init(frame: .zero)
        backgroundColor = .clear
        setupViewHierarchy()
        setupLayout()
        switchRightPanel(to: .lyrics, animated: false)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func switchRightPanel(to panel: NowPlayingRelaxedPanel, animated: Bool) {
        guard panel != currentRightPanel else {
            return
        }
        currentRightPanel = panel

        let incomingView: UIView
        let outgoingView: UIView

        switch panel {
        case .lyrics:
            incomingView = lyricsPanelView
            outgoingView = queuePanelView
        case .queue:
            incomingView = queuePanelView
            outgoingView = lyricsPanelView
        }

        guard animated else {
            outgoingView.alpha = 0
            outgoingView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            incomingView.alpha = 1
            incomingView.transform = .identity
            return
        }

        incomingView.alpha = 0
        incomingView.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)

        Interface.springAnimate(
            duration: 0.35,
            dampingRatio: 0.92,
            initialVelocity: 0.8,
        ) {
            outgoingView.alpha = 0
            outgoingView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            incomingView.alpha = 1
            incomingView.transform = .identity
        }
    }

    private func setupViewHierarchy() {
        addSubview(contentSafeAreaView)
        contentSafeAreaView.addSubview(leftPanelView)
        contentSafeAreaView.addSubview(rightPanelView)

        leftPanelView.addSubview(leftContentView)
        rightPanelView.addSubview(rightPanelContentContainer)
        rightPanelContentContainer.addSubview(lyricsPanelView)
        rightPanelContentContainer.addSubview(queuePanelView)
    }

    private func setupLayout() {
        contentSafeAreaView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
        }

        leftPanelView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        rightPanelView.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(contentSafeAreaView.snp.width).multipliedBy(0.5)
        }

        leftContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        rightPanelContentContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        lyricsPanelView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        queuePanelView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        queuePanelView.alpha = 0
        queuePanelView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
    }
}
