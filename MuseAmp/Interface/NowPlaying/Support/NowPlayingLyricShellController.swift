import UIKit

@MainActor
protocol NowPlayingLyricSheetPresenting: NowPlayingShellController {
    func presentLyricSelectionSheet(with lyrics: [String], activeIndex: Int?)
}

extension NowPlayingLyricSheetPresenting where Self: UIViewController {
    func presentLyricSelectionSheet(with lyrics: [String], activeIndex: Int?) {
        guard !lyrics.isEmpty,
              presentedViewController == nil
        else {
            return
        }

        let controller = LyricSelectionSheetViewController(lyrics: lyrics, activeIndex: activeIndex)
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .formSheet

        if let sheetPresentationController = navigationController.sheetPresentationController {
            sheetPresentationController.prefersGrabberVisible = true
        }

        present(navigationController, animated: true)
    }
}
