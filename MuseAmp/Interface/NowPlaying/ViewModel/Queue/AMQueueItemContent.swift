import Foundation

struct AMQueueItemContent: Hashable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let artworkURL: URL?
    let queueIndex: Int
    let isCurrent: Bool
    let isPlayed: Bool

    var positionText: String {
        isCurrent ? "\u{25B6}\u{FE0E} \(queueIndex + 1)" : "\(queueIndex + 1)"
    }
}
