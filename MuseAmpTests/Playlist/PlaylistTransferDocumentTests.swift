import Foundation
@testable import MuseAmp
import MuseAmpDatabaseKit
import Testing

@Suite(.serialized)
struct PlaylistTransferDocumentTests {
    @Test
    func `playlist transfer document round trip preserves playlist payload`() throws {
        let playlist = try Playlist(
            id: #require(UUID(uuidString: "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")),
            name: "Road Trip / Favorites",
            coverImageData: Data([0x01, 0x02, 0x03]),
            entries: [
                PlaylistEntry(
                    entryID: "entry-1",
                    trackID: "track-1",
                    title: "Opening",
                    artistName: "Artist A",
                    albumID: "album-1",
                    albumTitle: "First Album",
                    artworkURL: "https://example.com/1.jpg",
                    durationMillis: 180_000,
                    trackNumber: 1,
                    lyrics: "lyrics",
                ),
                PlaylistEntry(
                    entryID: "entry-2",
                    trackID: "track-2",
                    title: "Ending",
                    artistName: "Artist B",
                    albumID: "album-2",
                    albumTitle: "Second Album",
                    artworkURL: "https://example.com/2.jpg",
                    durationMillis: 200_000,
                    trackNumber: 2,
                ),
            ],
            createdAt: Date(timeIntervalSince1970: 1_710_000_000),
            updatedAt: Date(timeIntervalSince1970: 1_710_000_123),
        )

        let exportedAt = Date(timeIntervalSince1970: 1_715_555_555)
        let document = PlaylistTransferDocument(playlist: playlist, exportedAt: exportedAt)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let encoded = try encoder.encode(document)
        let decoded = try decoder.decode(PlaylistTransferDocument.self, from: encoded)

        #expect(decoded == document)
        #expect(document.exportFileName == "Road Trip Favorites.musiclist")
    }

    @Test
    func `playlist transfer document decodes legacy entries payload`() throws {
        let payload = """
        {
          "version": 1,
          "name": "Legacy Playlist",
          "entries": [
            {
              "trackID": "legacy-track",
              "title": "Legacy Song",
              "artistName": "Legacy Artist",
              "albumID": "legacy-album",
              "albumTitle": "Legacy Album",
              "durationMillis": 123000,
              "trackNumber": 7
            }
          ]
        }
        """

        let decoder = JSONDecoder()
        let document = try decoder.decode(PlaylistTransferDocument.self, from: Data(payload.utf8))

        #expect(document.name == "Legacy Playlist")
        #expect(document.songs.count == 1)
        #expect(document.songs[0].trackID == "legacy-track")
        #expect(document.songs[0].title == "Legacy Song")
        #expect(document.songs[0].artistName == "Legacy Artist")
        #expect(document.songs[0].albumID == "legacy-album")
        #expect(document.songs[0].albumTitle == "Legacy Album")
        #expect(document.songs[0].durationMillis == 123_000)
        #expect(document.songs[0].trackNumber == 7)
    }

    @Test
    func `audio track record playlist entry keeps import metadata`() {
        let track = makeMockTrack(
            trackID: "track-77",
            relativePath: "Artist/Album/Track 77.m4a",
            title: "Track 77",
            artistName: "Singer",
            albumTitle: "Album Title",
        )

        let entry = track.playlistEntry

        #expect(entry.trackID == "track-77")
        #expect(entry.title == "Track 77")
        #expect(entry.artistName == "Singer")
        #expect(entry.albumID == "album-1")
        #expect(entry.albumTitle == "Album Title")
        #expect(entry.durationMillis == 213_000)
        #expect(entry.trackNumber == 1)
    }
}
