import UIKit

@MainActor
enum ViewAnimationHelper {
    static func removeAnimationsRecursively(in view: UIView) {
        view.layer.removeAllAnimations()
        view.subviews.forEach { removeAnimationsRecursively(in: $0) }
    }
}
