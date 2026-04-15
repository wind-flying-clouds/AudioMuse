import AVKit
import Combine
import SnapKit
import UIKit

@MainActor
final class NowPlayingRoutePickerContainerView: UIView {
    private let playbackController: PlaybackController
    private var cancellables: Set<AnyCancellable> = []
    private weak var installedRoutePickerView: AVRoutePickerView?
    private var hasActiveTrack = false
    private var routeName = String(localized: "iPhone")

    init(playbackController: PlaybackController) {
        self.playbackController = playbackController
        super.init(frame: .zero)
        layer.cornerCurve = .continuous
        layer.cornerRadius = NowPlayingTransportView.Layout.buttonSize / 2
        bindDataSource()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func installRoutePickerView(_ routePickerView: AVRoutePickerView) {
        installedRoutePickerView = routePickerView
        subviews.forEach { $0.removeFromSuperview() }
        addSubview(routePickerView)
        routePickerView.tintColor = NowPlayingTransportView.Palette.primaryText
        routePickerView.activeTintColor = NowPlayingTransportView.Palette.primaryText
        routePickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        applyRouteState()
    }

    private func bindDataSource() {
        playbackController.$snapshot
            .map { ($0.currentTrack != nil, NowPlayingContentMapper.routeName(for: $0.outputDevice)) }
            .removeDuplicates { $0 == $1 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasActiveTrack, routeName in
                self?.hasActiveTrack = hasActiveTrack
                self?.routeName = routeName
                self?.applyRouteState()
            }
            .store(in: &cancellables)
    }

    private func applyRouteState() {
        isUserInteractionEnabled = hasActiveTrack
        alpha = hasActiveTrack ? 1 : NowPlayingTransportView.Layout.unavailableTransportButtonAlpha
        installedRoutePickerView?.isUserInteractionEnabled = hasActiveTrack
        installedRoutePickerView?.accessibilityLabel = String(localized: "Audio Route")
        installedRoutePickerView?.accessibilityValue = routeName
    }
}
