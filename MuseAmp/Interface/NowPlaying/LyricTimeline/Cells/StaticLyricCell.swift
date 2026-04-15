import UIKit

@MainActor
final class StaticLyricCell: LyricTimelineCell {
    override func applyActive(_: Bool) {
        super.applyActive(true)
    }
}
