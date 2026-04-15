import Foundation
import MuseAmpDatabaseKit

nonisolated enum PlaylistTransferFileType {
    static let identifier = "wiki.qaq.museamp.musiclist"
    static let fileExtension = ".musiclist"
    static let mimeType = "application/vnd.museamp.musiclist+json"
}

nonisolated struct PlaylistTransferDocument: Codable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case version
        case name
        case coverImageData
        case exportedAt
        case songs
        case entries
    }

    nonisolated struct SongReference: Codable, Equatable {
        let trackID: String
        let title: String
        let artistName: String
        let albumID: String?
        let albumTitle: String?
        let durationMillis: Int?
        let trackNumber: Int?

        init(entry: PlaylistEntry) {
            trackID = entry.trackID
            title = entry.title
            artistName = entry.artistName
            albumID = entry.albumID
            albumTitle = entry.albumTitle
            durationMillis = entry.durationMillis
            trackNumber = entry.trackNumber
        }
    }

    let version: Int
    let name: String
    let coverImageData: Data?
    let exportedAt: Date?
    let songs: [SongReference]

    init(playlist: Playlist, exportedAt: Date = .init()) {
        version = 1
        name = playlist.name
        coverImageData = playlist.coverImageData
        self.exportedAt = exportedAt
        songs = playlist.songs.map(SongReference.init(entry:))
    }

    var exportFileName: String {
        "\(sanitizeDisplayFileName(name, fallback: "Playlist"))\(PlaylistTransferFileType.fileExtension)"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 1
        name = try container.decode(String.self, forKey: .name)
        coverImageData = try container.decodeIfPresent(Data.self, forKey: .coverImageData)
        exportedAt = try container.decodeIfPresent(Date.self, forKey: .exportedAt)
        songs = try container.decodeIfPresent([SongReference].self, forKey: .songs)
            ?? container.decode([SongReference].self, forKey: .entries)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(coverImageData, forKey: .coverImageData)
        try container.encodeIfPresent(exportedAt, forKey: .exportedAt)
        try container.encode(songs, forKey: .songs)
    }
}
