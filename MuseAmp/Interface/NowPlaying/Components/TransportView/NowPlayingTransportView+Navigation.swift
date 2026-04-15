import LNPopupController
import UIKit

extension NowPlayingTransportView {
    func layoutAnimationContainerView() -> UIView {
        var responder: UIResponder? = self
        while let currentResponder = responder {
            if let viewController = currentResponder as? UIViewController {
                return viewController.view
            }
            responder = currentResponder.next
        }
        return self
    }

    func navigateToCurrentAlbum() {
        guard let track = environment.playbackController.snapshot.currentTrack else {
            return
        }
        guard let ownerViewController = owningViewController() else {
            return
        }
        guard let mainController = window?.rootViewController as? MainController else {
            return
        }

        ownerViewController.popupPresentationContainer?.closePopup(animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let navigationController: UINavigationController? = if mainController.currentLayoutMode == .compact {
                mainController.compactTabBarController.selectedViewController as? UINavigationController
            } else {
                mainController.activeContentNavigationController
            }
            guard let navigationController else {
                return
            }
            let helper = AlbumNavigationHelper(
                environment: mainController.environment,
                viewController: navigationController.topViewController,
            )
            helper.pushAlbumDetail(
                songID: track.id,
                albumID: track.albumID,
                albumName: track.albumName ?? "",
                artistName: track.artistName,
            )
        }
    }

    func owningViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let currentResponder = responder {
            if let viewController = currentResponder as? UIViewController {
                return viewController
            }
            responder = currentResponder.next
        }
        return nil
    }
}
