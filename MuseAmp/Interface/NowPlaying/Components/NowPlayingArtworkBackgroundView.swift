import ColorfulX
import SnapKit
import UIKit

@MainActor
final class NowPlayingArtworkBackgroundView: UIView {
    private nonisolated enum Appearance {
        static let speed: Double = 0.2
        static let bias: Double = 0.1
        static let noise: Double = 0
        static let transitionSpeed: Double = 1
        static let renderScale: Double = 0.25
    }

    private let gradientView: AnimatedMulticolorGradientView = {
        let view = AnimatedMulticolorGradientView()
        view.isUserInteractionEnabled = false
        view.isOpaque = false
        view.backgroundColor = .clear
        view.speed = Appearance.speed
        view.bias = Appearance.bias
        view.noise = Appearance.noise
        view.transitionSpeed = Appearance.transitionSpeed
        view.renderScale = Appearance.renderScale
        view.frameLimit = 30
        let gray = UIColor.gray
        view.setColors([gray, gray, gray, gray], animated: false, repeats: false)
        return view
    }()

    private let overlayView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }()

    private var isAnimationSuspended = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        clipsToBounds = true
        backgroundColor = .clear

        addSubview(gradientView)
        addSubview(overlayView)

        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func apply(colors: [UIColor]) {
        gradientView.setColors(colors, animated: true, repeats: true)
    }

    func setAnimationSuspended(_ suspended: Bool) {
        guard isAnimationSuspended != suspended else {
            return
        }

        isAnimationSuspended = suspended
        gradientView.speed = suspended ? 0 : Appearance.speed
        gradientView.transitionSpeed = suspended ? 0 : Appearance.transitionSpeed
    }
}
