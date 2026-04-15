import Foundation

protocol AMNowPlayingQueueTrackPresenting {
    var amQueueTrackID: String { get }
    var amQueueTrackTitle: String { get }
    var amQueueTrackSubtitle: String { get }
    var amQueueTrackArtworkURL: URL? { get }
    var amQueueTrackDurationInSeconds: TimeInterval? { get }
}
