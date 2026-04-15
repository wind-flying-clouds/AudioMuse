import UIKit

@MainActor
class AnimatedTextLabel: UILabel {
    var disablesAnimations = false {
        didSet {
            if disablesAnimations {
                layer.removeAllAnimations()
            }
        }
    }

    var textChangeAnimationDuration: TimeInterval = 0.18

    override var text: String? {
        didSet {
            animateTextTransition(
                previousValue: oldValue,
                currentValue: text,
            )
        }
    }

    override var attributedText: NSAttributedString? {
        didSet {
            animateTextTransition(
                previousValue: oldValue?.string,
                currentValue: attributedText?.string,
            )
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func animateTextTransition(
        previousValue: String?,
        currentValue: String?,
    ) {
        guard previousValue != currentValue else {
            return
        }
        guard !disablesAnimations, window != nil else {
            return
        }

        UIView.transition(
            with: self,
            duration: textChangeAnimationDuration,
            options: [.transitionCrossDissolve, .allowAnimatedContent, .beginFromCurrentState],
            animations: nil,
        )
    }
}
