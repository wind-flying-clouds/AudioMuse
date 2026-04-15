import Foundation

nonisolated struct TVLyricProgress: Sendable, Equatable {
    let line: TVLyricLine
    let index: Int
    let elapsed: TimeInterval
    let duration: TimeInterval?
    let progress: Double
}
