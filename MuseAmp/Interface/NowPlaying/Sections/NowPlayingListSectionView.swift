//
//  NowPlayingListSectionView.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/11.
//

import MuseAmpPlayerKit
import UIKit

enum NowPlayingQueueTrackSelection {
    case queue(index: Int)
}

final class NowPlayingListSectionView: NowPlayingQueueSectionView {
    typealias Layout = NowPlayingQueueSectionView.Layout
    typealias ItemIdentifier = NowPlayingQueueSectionView.ItemIdentifier

    var onSelectQueueTrack: (NowPlayingQueueTrackSelection) -> Void = { _ in }

    var isShuffleFeedbackActive = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        onSelectQueueItem = { [weak self] item in
            self?.onSelectQueueTrack(.queue(index: item.queueIndex))
        }
        updateQueue(queue: [], playerIndex: nil, repeatMode: .off)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        performPendingAutoScrollIfNeeded(animated: true)
    }

    override func didApplyQueueSnapshot() {
        performPendingAutoScrollIfNeeded(animated: true)
        AppLog.info(
            self,
            "queue snapshot finished visibleRows=\(queueTableView.indexPathsForVisibleRows?.count ?? 0)",
        )
    }

    override func logAutoScroll(targetOffsetY: CGFloat, animated: Bool) {
        AppLog.info(
            self,
            "queue refresh autoscroll targetOffsetY=\(String(format: "%.2f", targetOffsetY)) anchor=\(queueSnapshot.upcomingItems.isEmpty ? "controls-top" : "current-row@1/3") animated=\(animated) viewportHeight=\(String(format: "%.2f", queueTableView.bounds.height))",
        )
    }

    func updateQueue(
        queue: [PlaybackTrack],
        playerIndex: Int?,
        repeatMode: RepeatMode,
    ) {
        let nextSnapshot = makeQueueSnapshot(
            queue: queue,
            playerIndex: playerIndex,
            repeatMode: repeatMode,
        )
        let update = updateQueuePresentation(
            nextSnapshot: nextSnapshot,
            playerIndex: playerIndex,
        )

        AppLog.info(
            self,
            "queue refresh apply total=\(queue.count) history=\(queueSnapshot.historyItems.count) upcoming=\(queueSnapshot.upcomingItems.count) playerIndex=\(nowPlayingLogIndex(playerIndex)) repeatMode=\(String(describing: repeatMode)) identityChanged=\(update.didIdentityChange) contentChanged=\(update.didTrackContentChange) playerChanged=\(update.didPlayerIndexChange) headerChanged=\(update.didHeaderContentChange) footerChanged=\(update.didFooterContentChange)",
        )

        guard update.appliedSnapshot else {
            return
        }

        AppLog.info(
            self,
            "queue snapshot start history=\(queueSnapshot.historyItems.count) upcoming=\(queueSnapshot.upcomingItems.count)",
        )
    }

    func setShuffleFeedbackActive(_ isActive: Bool) {
        guard isShuffleFeedbackActive != isActive else {
            return
        }
        isShuffleFeedbackActive = isActive
        queueSnapshot = AMNowPlayingQueueSnapshot(
            historyItems: queueSnapshot.historyItems,
            upcomingItems: queueSnapshot.upcomingItems,
            headerContent: .controls(
                title: queueSnapshot.headerContent.title,
                repeatMode: queueSnapshot.headerContent.repeatMode,
                isShuffleFeedbackActive: isActive,
                isShuffleEnabled: queueSnapshot.headerContent.isShuffleEnabled,
            ),
            footerContent: queueSnapshot.footerContent,
        )
        refreshQueueControlsCell()
    }
}
