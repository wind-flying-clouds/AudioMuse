import Foundation

struct SongRowContent: Hashable {
    enum AppearanceStyle: Hashable {
        case standard
        case nowPlaying
    }

    let title: String
    let subtitle: String?
    let trailingText: String?
    let artwork: ArtworkContent
    let artworkURL: URL?
    let showsDownloadedIndicator: Bool
    let hidesTrailingText: Bool
    let appearanceStyle: AppearanceStyle

    init(
        title: String,
        subtitle: String? = nil,
        trailingText: String? = nil,
        artwork: ArtworkContent = ArtworkContent(placeholderIcon: "music.note", cornerRadius: 6),
        artworkURL: URL? = nil,
        showsDownloadedIndicator: Bool = false,
        hidesTrailingText: Bool = false,
        appearanceStyle: AppearanceStyle = .standard,
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailingText = trailingText
        self.artwork = artwork
        self.artworkURL = artworkURL
        self.showsDownloadedIndicator = showsDownloadedIndicator
        self.hidesTrailingText = hidesTrailingText
        self.appearanceStyle = appearanceStyle
    }
}
