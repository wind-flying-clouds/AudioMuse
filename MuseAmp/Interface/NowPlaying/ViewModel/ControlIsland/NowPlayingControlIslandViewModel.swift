import Combine
import Foundation

final class NowPlayingControlIslandViewModel {
    typealias Content = AMNowPlayingContent

    enum ContentSelector {
        case artwork
        case queue
        case lyrics
    }

    enum BackgroundSource: Equatable {
        case idle
        case artwork(url: URL)
    }

    struct Presentation: Equatable {
        let content: Content
        let backgroundSource: BackgroundSource
        let shouldAnimatePlaybackStateChange: Bool
        let shouldAnimateTransition: Bool

        init(
            content: Content,
            backgroundSource: BackgroundSource,
            shouldAnimatePlaybackStateChange: Bool,
            shouldAnimateTransition: Bool,
        ) {
            self.content = content
            self.backgroundSource = backgroundSource
            self.shouldAnimatePlaybackStateChange = shouldAnimatePlaybackStateChange
            self.shouldAnimateTransition = shouldAnimateTransition
        }
    }

    var content = Content.placeholder
    let contentSelectorPublisher = CurrentValueSubject<ContentSelector, Never>(.artwork)

    init() {}

    var selectedContentSelector: ContentSelector {
        contentSelectorPublisher.value
    }

    func setContentSelector(_ selector: ContentSelector) {
        guard selectedContentSelector != selector else {
            return
        }
        contentSelectorPublisher.send(selector)
    }
}
