import Combine
import Foundation
@testable import MuseAmp
import Testing

@Suite(.serialized)
struct AsyncMapLatestTests {
    @Test
    func `produces result from latest input`() async {
        let subject = PassthroughSubject<Int, Never>()
        var results: [String] = []
        let expectation = LockedBox(false)

        let cancellable = subject
            .asyncMapLatest { value -> String in
                "\(value)"
            }
            .sink { value in
                results.append(value)
                if results.count == 2 {
                    expectation.value = true
                }
            }

        subject.send(1)
        subject.send(2)

        for _ in 0 ..< 50 where !expectation.value {
            try? await Task.sleep(nanoseconds: 20_000_000)
        }

        #expect(results == ["1", "2"])
        _ = cancellable
    }

    @Test
    func `cancels in-flight work when new value arrives`() async {
        let subject = PassthroughSubject<Int, Never>()
        var results: [Int] = []
        let expectation = LockedBox(false)

        let cancellable = subject
            .asyncMapLatest { value -> Int in
                if value == 1 {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    return value
                }
                return value
            }
            .sink { value in
                results.append(value)
                expectation.value = true
            }

        subject.send(1)
        try? await Task.sleep(nanoseconds: 50_000_000)
        subject.send(2)

        for _ in 0 ..< 50 where !expectation.value {
            try? await Task.sleep(nanoseconds: 20_000_000)
        }

        #expect(results == [2])
        _ = cancellable
    }

    @Test
    func `handles nil passthrough`() async {
        let subject = PassthroughSubject<String?, Never>()
        var results: [String?] = []
        let expectation = LockedBox(false)

        let cancellable = subject
            .asyncMapLatest { value -> String? in
                value
            }
            .sink { value in
                results.append(value)
                if results.count == 2 {
                    expectation.value = true
                }
            }

        subject.send(nil)
        subject.send("hello")

        for _ in 0 ..< 50 where !expectation.value {
            try? await Task.sleep(nanoseconds: 20_000_000)
        }

        #expect(results.count == 2)
        #expect(results[0] == nil)
        #expect(results[1] == "hello")
        _ = cancellable
    }
}

private final class LockedBox<T: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: T

    init(_ value: T) {
        _value = value
    }

    var value: T {
        get { lock.withLock { _value } }
        set { lock.withLock { _value = newValue } }
    }
}
