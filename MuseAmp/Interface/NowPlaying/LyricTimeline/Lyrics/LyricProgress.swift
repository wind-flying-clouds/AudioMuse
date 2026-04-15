import Foundation

nonisolated struct LyricProgress: Sendable, Equatable {
    let line: LyricLine
    let index: Int
    let elapsed: TimeInterval
    let duration: TimeInterval?
    let progress: Double
}
