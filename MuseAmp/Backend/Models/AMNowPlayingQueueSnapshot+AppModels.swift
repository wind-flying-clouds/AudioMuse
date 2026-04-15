//
//  AMNowPlayingQueueSnapshot+AppModels.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/11.
//

import Foundation
import MuseAmpPlayerKit

extension PlaybackTrack: AMNowPlayingQueueTrackPresenting {
    var amQueueTrackID: String {
        id
    }

    var amQueueTrackTitle: String {
        title.sanitizedTrackTitle
    }

    var amQueueTrackSubtitle: String {
        artistName
    }

    var amQueueTrackArtworkURL: URL? {
        artworkURL
    }

    var amQueueTrackDurationInSeconds: TimeInterval? {
        durationInSeconds
    }
}

extension AMPlaybackRepeatMode {
    init(_ repeatMode: RepeatMode) {
        switch repeatMode {
        case .off:
            self = .off
        case .track:
            self = .track
        case .queue:
            self = .queue
        }
    }
}
