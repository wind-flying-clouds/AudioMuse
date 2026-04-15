struct MediaRowContent: Hashable {
    let title: String
    let subtitle: String?
    let artwork: ArtworkContent

    init(
        title: String,
        subtitle: String? = nil,
        artwork: ArtworkContent,
    ) {
        self.title = title
        self.subtitle = subtitle
        self.artwork = artwork
    }
}
