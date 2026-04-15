import Foundation

nonisolated enum SearchTextMatcher {
    static func matches(_ text: String, query: String) -> Bool {
        matches(text, queryForms: normalizedQueryForms(for: query))
    }

    static func matches(_ text: String, queryForms: [String]) -> Bool {
        guard !text.isEmpty, !queryForms.isEmpty else {
            return false
        }

        let candidateForms = normalizedTextForms(for: text)
        return candidateForms.contains { candidate in
            queryForms.contains { query in
                candidate.contains(query)
            }
        }
    }

    static func highlightRanges(in text: String, query: String) -> [NSRange] {
        let queryForms = normalizedQueryForms(for: query)
        guard !text.isEmpty, !queryForms.isEmpty else {
            return []
        }

        let originalLength = (text as NSString).length
        let candidateForms = ChineseScriptSearchNormalizer.searchForms(for: text)
            .compactMap { candidate -> String? in
                guard (candidate as NSString).length == originalLength else {
                    return nil
                }
                return normalizedText(candidate)
            }

        var ranges: [NSRange] = []
        var seen = Set<String>()

        for candidate in candidateForms {
            let candidateNSString = candidate as NSString
            for queryForm in queryForms {
                var searchStart = 0
                while searchStart < candidateNSString.length {
                    let range = candidateNSString.range(
                        of: queryForm,
                        range: NSRange(
                            location: searchStart,
                            length: candidateNSString.length - searchStart,
                        ),
                    )
                    guard range.location != NSNotFound else {
                        break
                    }

                    let key = "\(range.location):\(range.length)"
                    if seen.insert(key).inserted {
                        ranges.append(range)
                    }
                    searchStart = range.location + max(range.length, 1)
                }
            }
        }

        return ranges.sorted {
            if $0.location != $1.location {
                return $0.location < $1.location
            }
            return $0.length < $1.length
        }
    }

    static func normalizedQueryForms(for query: String) -> [String] {
        ChineseScriptSearchNormalizer.searchForms(for: query)
            .map(normalizedText(_:))
            .filter { !$0.isEmpty }
    }

    private static func normalizedTextForms(for text: String) -> [String] {
        ChineseScriptSearchNormalizer.searchForms(for: text)
            .map(normalizedText(_:))
            .filter { !$0.isEmpty }
    }

    private static func normalizedText(_ text: String) -> String {
        ChineseScriptSearchNormalizer.canonicalSearchKey(text)
    }
}
