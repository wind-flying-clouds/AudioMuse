import Foundation

enum AMPlaybackRepeatMode: Equatable {
    case off
    case track
    case queue
}

protocol AMPlaybackControlling: AnyObject {
    var isPlaying: Bool { get }
    var isShuffleEnabled: Bool { get }
    var repeatMode: AMPlaybackRepeatMode { get }

    func play()
    func pause()
    func togglePlayPause()
    func next()
    func previous()
    func seek(to seconds: TimeInterval)
}
