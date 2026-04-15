import Foundation

nonisolated enum TrackTitleSanitizer {
    private struct TrailingPattern {
        let key: String
        let trimmedPrefix: String
    }

    private static let bracketPairs: [(open: Character, close: Character)] = [
        ("(", ")"),
        ("（", "）"),
        ("[", "]"),
        ("【", "】"),
    ]

    private static let lock = NSLock()
    private nonisolated(unsafe) static var trailingPatternCounts: [String: Int] = [:]

    static func refresh(titles: [String]) {
        var counts: [String: Int] = [:]

        for title in titles {
            var remainingTitle = title
            var seenKeys = Set<String>()

            while let pattern = trailingPattern(in: remainingTitle) {
                seenKeys.insert(pattern.key)
                remainingTitle = pattern.trimmedPrefix
            }

            for key in seenKeys {
                counts[key, default: 0] += 1
            }
        }

        lock.lock()
        trailingPatternCounts = counts
        lock.unlock()
    }

    static func sanitize(_ title: String, forceEnabled: Bool? = nil) -> String {
        guard forceEnabled ?? AppPreferences.isCleanSongTitleEnabled else {
            return title
        }

        lock.lock()
        let patternCounts = trailingPatternCounts
        lock.unlock()

        var remainingTitle = title
        while let pattern = trailingPattern(in: remainingTitle),
              patternCounts[pattern.key, default: 0] >= 2
        {
            remainingTitle = pattern.trimmedPrefix
        }

        let trimmed = remainingTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? title : trimmed
    }

    private static func trailingPattern(in title: String) -> TrailingPattern? {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            return nil
        }

        if let bracketPattern = bracketTrailingPattern(in: trimmedTitle) {
            return bracketPattern
        }

        return dashTrailingPattern(in: trimmedTitle)
    }

    private static func bracketTrailingPattern(in title: String) -> TrailingPattern? {
        guard let lastCharacter = title.last,
              let pair = bracketPairs.first(where: { $0.close == lastCharacter }),
              let closeIndex = title.indices.last
        else {
            return nil
        }

        guard let openIndex = matchingOpenBracket(
            in: title,
            closeIndex: closeIndex,
            open: pair.open,
            close: pair.close,
        ) else {
            return nil
        }

        let contentStart = title.index(after: openIndex)
        let content = String(title[contentStart ..< closeIndex])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else {
            return nil
        }

        var prefixEnd = openIndex
        while prefixEnd > title.startIndex {
            let previousIndex = title.index(before: prefixEnd)
            guard title[previousIndex].isWhitespace else {
                break
            }
            prefixEnd = previousIndex
        }

        let prefix = String(title[..<prefixEnd])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prefix.isEmpty else {
            return nil
        }

        return TrailingPattern(
            key: "bracket:\(canonicalPatternKey(content))",
            trimmedPrefix: prefix,
        )
    }

    private static func dashTrailingPattern(in title: String) -> TrailingPattern? {
        guard let separatorRange = title.range(of: " - ", options: .backwards) else {
            return nil
        }

        let suffix = String(title[separatorRange.upperBound...])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !suffix.isEmpty else {
            return nil
        }

        let prefix = String(title[..<separatorRange.lowerBound])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prefix.isEmpty else {
            return nil
        }

        return TrailingPattern(
            key: "dash:\(canonicalPatternKey(suffix))",
            trimmedPrefix: prefix,
        )
    }

    private static func canonicalPatternKey(_ text: String) -> String {
        ChineseScriptSearchNormalizer.canonicalSearchKey(text)
    }

    private static func matchingOpenBracket(
        in title: String,
        closeIndex: String.Index,
        open: Character,
        close: Character,
    ) -> String.Index? {
        var index = closeIndex
        var depth = 0

        while true {
            let character = title[index]
            if character == close {
                depth += 1
            } else if character == open {
                depth -= 1
                if depth == 0 {
                    return index
                }
            }

            guard index > title.startIndex else {
                return nil
            }
            index = title.index(before: index)
        }
    }
}
