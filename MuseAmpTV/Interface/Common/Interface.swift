import UIKit

@MainActor
enum Interface {
    static let interruptibleOptions: UIView.AnimationOptions = [
        .beginFromCurrentState, .allowUserInteraction,
    ]

    static func smoothSpringAnimate(
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil,
    ) {
        UIView.animate(
            withDuration: 1.0,
            delay: 0,
            usingSpringWithDamping: 1.05,
            initialSpringVelocity: 0.75,
            options: interruptibleOptions.union(.curveEaseInOut),
            animations: animations,
            completion: completion,
        )
    }

    static func animate(
        duration: TimeInterval,
        delay: TimeInterval = 0,
        options: UIView.AnimationOptions = [],
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil,
    ) {
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: interruptibleOptions.union(options),
            animations: animations,
            completion: completion,
        )
    }
}
