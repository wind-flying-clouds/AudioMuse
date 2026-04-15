import Foundation

nonisolated enum ChineseScriptSearchNormalizer {
    enum Script {
        case simplified
        case traditional
    }

    static func convert(_ text: String, to script: Script) -> String {
        let transform: CFString = switch script {
        case .simplified:
            "Hant-Hans" as CFString
        case .traditional:
            "Hans-Hant" as CFString
        }

        let mutable = NSMutableString(string: text)
        CFStringTransform(mutable, nil, transform, false)
        return mutable as String
    }

    static func searchForms(for text: String) -> [String] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return []
        }

        var orderedForms: [String] = []
        var seen = Set<String>()

        for candidate in [
            trimmed,
            convert(trimmed, to: .simplified),
            convert(trimmed, to: .traditional),
        ] {
            let key = canonicalSearchKey(candidate)
            guard !key.isEmpty, seen.insert(key).inserted else {
                continue
            }
            orderedForms.append(candidate)
        }

        return orderedForms
    }

    static func canonicalSearchKey(_ text: String) -> String {
        convert(text, to: .simplified)
            .folding(
                options: [
                    .caseInsensitive,
                    .diacriticInsensitive,
                    .widthInsensitive,
                ],
                locale: .current,
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
