//
//  LyricTimelineView+Actions.swift
//  MuseAmp
//
//  Created by qaq on 14/4/2026.
//

import UIKit

// MARK: - Actions

extension LyricTimelineView {
    func seekToLine(at row: Int) {
        guard let timeline = currentTimeline(),
              case let .line(index, _, _) = items[row],
              timeline.lines.indices.contains(index)
        else { return }
        let time = timeline.lines[index].time
        environment.playbackController.seek(to: time)
        environment.playbackController.play()
    }

    func makeLineContextMenu(at row: Int) -> UIMenu? {
        guard case let .line(index, _, _) = items[row] else { return nil }

        var playFromHereActions: [UIAction] = []
        if let timeline = currentTimeline(), timeline.lines.indices.contains(index) {
            let time = timeline.lines[index].time
            let formatted = Self.formatTimestamp(time)
            playFromHereActions.append(
                UIAction(
                    title: String(localized: "Play from Here"),
                    subtitle: formatted,
                    image: UIImage(systemName: "play.fill"),
                ) { [weak self] _ in
                    self?.environment.playbackController.seek(to: time)
                    self?.environment.playbackController.play()
                },
            )
        }

        let allLines = currentLyricLines()
        let activeIndex = items.firstIndex(where: {
            if case let .line(_, _, isActive) = $0 { return isActive }
            return false
        }).flatMap { row -> Int? in
            if case let .line(idx, _, _) = items[row] { return idx }
            return nil
        }

        let copy = UIAction(
            title: String(localized: "Copy"),
            image: UIImage(systemName: "doc.on.doc"),
        ) { _ in
            UIPasteboard.general.string = allLines.joined(separator: "\n")
            #if os(iOS)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            #endif
        }

        let selectCopy = UIAction(
            title: String(localized: "Select & Copy"),
            image: UIImage(systemName: "text.badge.checkmark"),
        ) { [weak self] _ in
            self?.presentLyricSelectionSheet(lyrics: allLines, activeIndex: activeIndex)
        }

        let playSection = UIMenu(options: .displayInline, children: playFromHereActions)
        let copySection = UIMenu(options: .displayInline, children: [copy, selectCopy])
        return UIMenu(children: [playSection, copySection])
    }

    private func presentLyricSelectionSheet(lyrics: [String], activeIndex: Int?) {
        guard !lyrics.isEmpty else { return }
        guard let viewController = sequence(first: self as UIResponder, next: \.next)
            .compactMap({ $0 as? UIViewController })
            .first
        else { return }
        guard viewController.presentedViewController == nil else { return }

        let controller = LyricSelectionSheetViewController(lyrics: lyrics, activeIndex: activeIndex)
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .formSheet
        if let sheet = nav.sheetPresentationController {
            sheet.prefersGrabberVisible = true
        }
        viewController.present(nav, animated: true)
    }

    private func currentTimeline() -> LyricTimeline? {
        let trackID = environment.playbackController.snapshot.currentTrack?.id
        guard let trackID else { return nil }
        let cached = environment.lyricsService.cachedLyrics(for: trackID)
        guard let cached, !cached.isEmpty else { return nil }
        let converted = if AppPreferences.isLyricsAutoConvertChineseEnabled {
            LyricsChineseScriptConverter.convertToSystemScript(cached)
        } else {
            cached
        }
        let timeline = LyricTimeline(lrc: converted)
        return timeline.lines.isEmpty ? nil : timeline
    }

    private func currentLyricLines() -> [String] {
        items.compactMap {
            if case let .line(_, text, _) = $0 { return text }
            return nil
        }.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    nonisolated static func formatTimestamp(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds))
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d", m, s)
    }
}
