import AVKit
import LNPopupController
import UIKit

@MainActor
protocol NowPlayingArtworkShellPresenting: AnyObject {
    var onArtworkLoaded: (URL, UIImage) -> Void { get set }

    func installRoutePickerView(_ routePickerView: AVRoutePickerView)
}

extension NowPlayingCompactPageController: NowPlayingArtworkShellPresenting {}

extension NowPlayingRelaxedController: NowPlayingArtworkShellPresenting {
    var onArtworkLoaded: (URL, UIImage) -> Void {
        get { centerSectionView.onArtworkLoaded }
        set { centerSectionView.onArtworkLoaded = newValue }
    }

    func installRoutePickerView(_ routePickerView: AVRoutePickerView) {
        relaxedTransportView.installRoutePickerView(routePickerView)
    }
}

@MainActor
protocol NowPlayingArtworkShellController: NowPlayingPlaybackShellController {
    var routePickerPresenter: NowPlayingRoutePickerPresenter { get }
}

extension NowPlayingArtworkShellController where Self: UIViewController {
    func bindArtworkSectionActions(_ section: some NowPlayingArtworkShellPresenting) {
        section.onArtworkLoaded = { [weak self] url, image in
            guard let self else { return }
            artworkBackgroundCoordinator.updateFromDisplayedArtwork(url: url, image: image)
            guard currentPlaybackSnapshot.currentTrack?.artworkURL == url else { return }
            popupItem.image = image
        }
        section.installRoutePickerView(routePickerPresenter.routePickerView)
    }
}
