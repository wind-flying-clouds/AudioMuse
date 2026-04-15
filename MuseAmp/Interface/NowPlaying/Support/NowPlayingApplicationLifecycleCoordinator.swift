//
//  NowPlayingApplicationLifecycleCoordinator.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/11.
//

import UIKit

@MainActor
final class NowPlayingApplicationLifecycleCoordinator {
    private let onSuspensionChanged: (Bool) -> Void
    private nonisolated(unsafe) var didEnterBackgroundObserver: NSObjectProtocol?
    private nonisolated(unsafe) var didBecomeActiveObserver: NSObjectProtocol?

    init(onSuspensionChanged: @escaping (Bool) -> Void) {
        self.onSuspensionChanged = onSuspensionChanged
    }

    deinit {
        if let didEnterBackgroundObserver {
            NotificationCenter.default.removeObserver(didEnterBackgroundObserver)
        }
        if let didBecomeActiveObserver {
            NotificationCenter.default.removeObserver(didBecomeActiveObserver)
        }
    }

    func bind() {
        guard didEnterBackgroundObserver == nil,
              didBecomeActiveObserver == nil
        else {
            return
        }

        didEnterBackgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main,
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.onSuspensionChanged(true)
            }
        }

        didBecomeActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main,
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.onSuspensionChanged(false)
            }
        }

        onSuspensionChanged(UIApplication.shared.applicationState != .active)
    }
}
