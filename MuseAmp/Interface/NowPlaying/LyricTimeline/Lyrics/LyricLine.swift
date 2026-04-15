import Foundation

nonisolated struct LyricLine: Sendable, Equatable {
    let time: TimeInterval
    let text: String
}
