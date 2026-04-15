import Foundation

enum AMNowPlayingQueueSnapshotBuilder {
    static func makeSnapshot(
        queue: [some AMNowPlayingQueueTrackPresenting],
        playerIndex: Int?,
        repeatMode: AMPlaybackRepeatMode,
        isShuffleFeedbackActive: Bool,
        title: String,
        historyLimit: Int = NowPlayingQueueSectionView.Layout.maxVisibleHistoryTracks,
        queueLimit: Int = NowPlayingQueueSectionView.Layout.maxVisibleQueueTracks,
    ) -> AMNowPlayingQueueSnapshot {
        var occurrences: [String: Int] = [:]
        var allHistory: [AMQueueItemContent] = []
        var allQueue: [AMQueueItemContent] = []

        allHistory.reserveCapacity(playerIndex ?? 0)
        allQueue.reserveCapacity(queue.count)

        for (queueIndex, track) in queue.enumerated() {
            let occurrence = occurrences[track.amQueueTrackID, default: 0]
            occurrences[track.amQueueTrackID] = occurrence + 1

            let isHistoryTrack = playerIndex.map { queueIndex < $0 } ?? false
            let item = AMQueueItemContent(
                id: NowPlayingQueueSectionView.ItemIdentifier.track(
                    trackID: track.amQueueTrackID,
                    occurrence: occurrence,
                ),
                title: track.amQueueTrackTitle,
                subtitle: track.amQueueTrackSubtitle,
                artworkURL: track.amQueueTrackArtworkURL,
                queueIndex: queueIndex,
                isCurrent: queueIndex == playerIndex,
                isPlayed: isHistoryTrack,
            )

            if isHistoryTrack {
                allHistory.append(item)
            } else {
                allQueue.append(item)
            }
        }

        let trimmedHistory = allHistory.suffix(historyLimit)
        let trimmedQueue = allQueue.prefix(queueLimit)
        return AMNowPlayingQueueSnapshot(
            historyItems: Array(trimmedHistory),
            upcomingItems: Array(trimmedQueue),
            headerContent: .controls(
                title: title,
                repeatMode: repeatMode,
                isShuffleFeedbackActive: isShuffleFeedbackActive,
                isShuffleEnabled: queue.count > 1,
            ),
            footerContent: makeFooterContent(
                queue: queue,
                playerIndex: playerIndex,
                queueLimit: queueLimit,
            ),
        )
    }

    private static func makeFooterContent(
        queue: [some AMNowPlayingQueueTrackPresenting],
        playerIndex: Int?,
        queueLimit: Int,
    ) -> AMNowPlayingQueueFooterContent? {
        guard let idx = playerIndex else { return nil }
        let totalUpcoming = queue.count - idx
        guard totalUpcoming > queueLimit else {
            return nil
        }
        let upcomingTracks = queue[idx...]
        let totalSeconds = upcomingTracks.reduce(0.0) { $0 + ($1.amQueueTrackDurationInSeconds ?? 0) }
        return AMNowPlayingQueueFooterContent(
            remainingCount: max(totalUpcoming - queueLimit, 0),
            totalMinutes: Int((totalSeconds / 60).rounded()),
        )
    }
}
