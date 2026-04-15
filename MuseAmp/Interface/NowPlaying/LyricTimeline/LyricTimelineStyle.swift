import UIKit

nonisolated enum LyricTimelineAnimation {
    static let initialRevealDuration: TimeInterval = 0.32
    static let initialRevealStagger: TimeInterval = 0.035
    static let outgoingFadeDuration: TimeInterval = 0.16
    static let outgoingFadeStagger: TimeInterval = 0.04
    static let plainRevealDuration: TimeInterval = 0.26
    static let plainRevealTranslationY: CGFloat = 12
    static let easeOutOptions: UIView.AnimationOptions = .curveEaseOut
}

nonisolated enum LyricTimelineLineStyle {
    static let textFont = UIFontMetrics(forTextStyle: .title2).scaledFont(
        for: .systemFont(ofSize: 28, weight: .bold),
    )
    static let activeAlpha: CGFloat = 1.0
    static let inactiveAlpha: CGFloat = 0.25
    static let tapHighlightCornerRadius: CGFloat = 14
    static let estimatedLineHeight = ceil(textFont.lineHeight)
}
