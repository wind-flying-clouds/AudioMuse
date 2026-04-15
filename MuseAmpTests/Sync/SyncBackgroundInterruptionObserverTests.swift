@testable import MuseAmp
import Testing
import UIKit

@Suite(.serialized)
@MainActor
struct SyncBackgroundInterruptionObserverTests {
    @Test
    func `permission prompt inactive transition does not interrupt sync`() {
        let notificationCenter = NotificationCenter()
        let counter = InterruptionCounter()
        let observer = SyncBackgroundInterruptionObserver(notificationCenter: notificationCenter) {
            counter.increment()
        }

        observer.start()
        notificationCenter.post(name: UIApplication.willResignActiveNotification, object: nil)

        #expect(counter.value == 0)

        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)

        #expect(counter.value == 1)
    }

    @Test
    func `stopping observer ignores later background transitions`() {
        let notificationCenter = NotificationCenter()
        let counter = InterruptionCounter()
        let observer = SyncBackgroundInterruptionObserver(notificationCenter: notificationCenter) {
            counter.increment()
        }

        observer.start()
        observer.stop()
        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)

        #expect(counter.value == 0)
    }
}

private final nonisolated class InterruptionCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var _value = 0

    func increment() {
        lock.withLock { _value += 1 }
    }

    var value: Int {
        lock.withLock { _value }
    }
}
