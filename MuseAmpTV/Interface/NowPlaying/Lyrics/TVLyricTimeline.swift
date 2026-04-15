import Foundation

nonisolated struct TVLyricTimeline: Sendable, Equatable {
    let lines: [TVLyricLine]

    nonisolated init(lrc: String) {
        lines = TVLyricParser.parse(lrc: lrc)
    }

    func progress(at currentTime: TimeInterval) -> TVLyricProgress? {
        guard !lines.isEmpty else { return nil }

        let index = activeLineIndex(at: currentTime)
        guard index >= 0 else { return nil }

        let line = lines[index]
        let elapsed = max(0, currentTime - line.time)
        let nextLine = lines.indices.contains(index + 1) ? lines[index + 1] : nil

        if let nextLine {
            let duration = max(nextLine.time - line.time, 0)
            let progress: Double = if duration > 0 {
                min(max(elapsed / duration, 0), 1)
            } else {
                1
            }
            return TVLyricProgress(line: line, index: index, elapsed: elapsed, duration: duration, progress: progress)
        }

        return TVLyricProgress(line: line, index: index, elapsed: elapsed, duration: nil, progress: 1)
    }

    private func activeLineIndex(at currentTime: TimeInterval) -> Int {
        var lowerBound = 0
        var upperBound = lines.count

        while lowerBound < upperBound {
            let midpoint = lowerBound + (upperBound - lowerBound) / 2
            if lines[midpoint].time <= currentTime {
                lowerBound = midpoint + 1
            } else {
                upperBound = midpoint
            }
        }

        return lowerBound - 1
    }
}
