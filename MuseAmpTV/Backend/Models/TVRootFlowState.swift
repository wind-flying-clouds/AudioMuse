import Foundation

enum AMTVRootFlowState: Equatable {
    case awaitingUpload
    case receivingTracks
    case playing
    case failed
}
