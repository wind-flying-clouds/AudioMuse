//
//  SearchHighlightHelper.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/11.
//

import UIKit

enum SearchHighlightHelper {
    static func attributedString(
        text: String,
        query: String,
        font: UIFont,
        color: UIColor,
        highlightColor: UIColor = .tintColor,
    ) -> NSAttributedString {
        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [.font: font, .foregroundColor: color],
        )
        guard !query.isEmpty else { return attributed }

        let highlightFont = UIFont.systemFont(ofSize: font.pointSize, weight: .semibold)
        for range in SearchTextMatcher.highlightRanges(in: text, query: query) {
            attributed.addAttributes(
                [.font: highlightFont, .foregroundColor: highlightColor],
                range: range,
            )
        }

        return attributed
    }
}
