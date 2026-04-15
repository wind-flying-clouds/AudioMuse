import Foundation

enum AMNowPlayingQueueHeaderContent: Equatable {
    case title(String)
    case controls(
        title: String,
        repeatMode: AMPlaybackRepeatMode,
        isShuffleFeedbackActive: Bool,
        isShuffleEnabled: Bool,
    )
}

extension AMNowPlayingQueueHeaderContent {
    var title: String {
        switch self {
        case let .title(title):
            title
        case let .controls(title, _, _, _):
            title
        }
    }

    var repeatMode: AMPlaybackRepeatMode {
        switch self {
        case .title:
            .off
        case let .controls(_, repeatMode, _, _):
            repeatMode
        }
    }

    var isShuffleFeedbackActive: Bool {
        switch self {
        case .title:
            false
        case let .controls(_, _, isShuffleFeedbackActive, _):
            isShuffleFeedbackActive
        }
    }

    var isShuffleEnabled: Bool {
        switch self {
        case .title:
            false
        case let .controls(_, _, _, isShuffleEnabled):
            isShuffleEnabled
        }
    }
}
