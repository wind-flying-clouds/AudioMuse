import CoreGraphics
import Foundation

struct AMNowPlayingContent: Equatable {
    let trackID: String
    let title: String
    let subtitle: String
    let currentTime: TimeInterval
    let duration: TimeInterval
    let hasActiveTrack: Bool
    let isPlaying: Bool
    let isPreviousAvailable: Bool
    let isFavorite: Bool
    let routeName: String
    let routeSymbolName: String
}

extension AMNowPlayingContent {
    static let placeholder = AMNowPlayingContent(
        trackID: "",
        title: String(localized: "Nothing Playing"),
        subtitle: String(localized: "Pick a song to get started"),
        currentTime: 0,
        duration: 0,
        hasActiveTrack: false,
        isPlaying: false,
        isPreviousAvailable: false,
        isFavorite: false,
        routeName: String(localized: "iPhone"),
        routeSymbolName: "iphone",
    )

    var artist: String {
        subtitle
    }

    var elapsedText: String {
        formattedPlaybackTime(currentTime)
    }

    var remainingText: String {
        "-\(formattedPlaybackTime(max(duration - currentTime, 0)))"
    }

    var progress: CGFloat {
        guard duration > 0 else {
            return 0
        }
        return CGFloat(min(max(currentTime / duration, 0), 1))
    }
}
