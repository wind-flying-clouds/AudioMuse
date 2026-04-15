//
//  AlbumTrackCellContent+AppModels.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/11.
//

import Foundation
import SubsonicClientKit

extension AlbumTrackCellContent {
    init(
        number: Int,
        catalogSong: CatalogSong,
        isHighlighted: Bool = false,
        isDownloaded: Bool = false,
        isPlaying: Bool = false,
    ) {
        self.init(
            number: number,
            title: catalogSong.attributes.name,
            durationText: catalogSong.attributes.durationInMillis.map { formattedDuration(millis: $0) },
            isExplicit: catalogSong.attributes.contentRating == "explicit",
            isHighlighted: isHighlighted,
            isDownloaded: isDownloaded,
            isPlaying: isPlaying,
        )
    }
}
