import Foundation

struct AMNowPlayingQueueSnapshot: Equatable {
    let historyItems: [AMQueueItemContent]
    let upcomingItems: [AMQueueItemContent]
    let headerContent: AMNowPlayingQueueHeaderContent
    let footerContent: AMNowPlayingQueueFooterContent?
}

extension AMNowPlayingQueueSnapshot {
    static let empty = AMNowPlayingQueueSnapshot(
        historyItems: [],
        upcomingItems: [],
        headerContent: .controls(
            title: String(localized: "Player Queue"),
            repeatMode: .off,
            isShuffleFeedbackActive: false,
            isShuffleEnabled: false,
        ),
        footerContent: nil,
    )
}
