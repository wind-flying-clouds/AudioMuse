//
//  NowPlayingListSectionView+DataSource.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/11.
//

import Foundation
import MuseAmpPlayerKit

extension NowPlayingListSectionView {
    func makeQueueSnapshot(
        queue: [PlaybackTrack],
        playerIndex: Int?,
        repeatMode: RepeatMode,
    ) -> AMNowPlayingQueueSnapshot {
        AMNowPlayingQueueSnapshotBuilder.makeSnapshot(
            queue: queue,
            playerIndex: playerIndex,
            repeatMode: AMPlaybackRepeatMode(repeatMode),
            isShuffleFeedbackActive: isShuffleFeedbackActive,
            title: String(localized: "Player Queue"),
            historyLimit: Layout.maxVisibleHistoryTracks,
            queueLimit: Layout.maxVisibleQueueTracks,
        )
    }
}
