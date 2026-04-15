//
//  NowPlayingQueueShuffleFeedbackCoordinator.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/11.
//

import Foundation

@MainActor
final class NowPlayingQueueShuffleFeedbackCoordinator {
    private let setFeedbackActive: (Bool) -> Void
    private var feedbackTask: Task<Void, Never>?

    init(setFeedbackActive: @escaping (Bool) -> Void) {
        self.setFeedbackActive = setFeedbackActive
    }

    deinit {
        feedbackTask?.cancel()
    }

    func cancel() {
        feedbackTask?.cancel()
        feedbackTask = nil
        setFeedbackActive(false)
    }

    func performShuffle(action: @escaping () async -> Void) {
        cancel()
        setFeedbackActive(true)

        Task {
            await action()
        }

        feedbackTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled, let self else { return }
            feedbackTask = nil
            setFeedbackActive(false)
        }
    }
}
