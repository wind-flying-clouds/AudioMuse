import Foundation
@testable import SubsonicClientKit
import Testing

// MARK: - Fixture Loader

private enum LiveFixture {
    static let baseURL = URL(string: "https://music.example.com/rest")!

    static func load(_ name: String) throws -> Data {
        let url = try #require(Bundle.module.url(forResource: name, withExtension: "json"))
        return try Data(contentsOf: url)
    }

    static func makeSession(fixtureMap: @escaping (String) -> String) -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [LiveFixtureURLProtocol.self]
        LiveFixtureURLProtocol.fixtureMap = fixtureMap
        return URLSession(configuration: config)
    }

    static func httpResponse(for request: URLRequest, statusCode: Int = 200) -> HTTPURLResponse {
        HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"],
        )!
    }
}

private final class LiveFixtureURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var fixtureMap: ((String) -> String)?

    override class func canInit(with _: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let map = Self.fixtureMap else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        let action = request.url?.lastPathComponent ?? ""
        let fixtureName = map(action)
        do {
            let data = try LiveFixture.load(fixtureName)
            let response = LiveFixture.httpResponse(for: request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Ping

@Suite(.serialized)
struct LiveFixtureTests {}

// MARK: - Ping

extension LiveFixtureTests {
    @Test
    func `ping decodes ok response`() async throws {
        let session = LiveFixture.makeSession { _ in "ping_ok" }
        let service = SubsonicMusicService(
            baseURL: LiveFixture.baseURL,
            username: "user",
            password: "pass",
            session: session,
        )
        try await service.ping()
    }
}

// MARK: - Search

extension LiveFixtureTests {
    @Test
    func `search maps live song results with CJK metadata`() async throws {
        let session = LiveFixture.makeSession { _ in "search3_test" }
        let service = SubsonicMusicService(
            baseURL: LiveFixture.baseURL,
            username: "user",
            password: "pass",
            session: session,
        )

        let response = try await service.search(
            query: "test",
            type: .song,
            limit: 3,
            offset: 0,
            cacheSearchResponses: false,
            prefetchSongMetadata: false,
        )

        let songs = try #require(response.results.songs)
        #expect(songs.data.count == 3)

        let first = songs.data[0]
        #expect(first.id == "1554079707")
        #expect(first.attributes.name == "TEST")
        #expect(first.attributes.artistName == "邓典果DDG")
        #expect(first.attributes.albumName == "ALL I DO IS DRILLING")
        #expect(first.attributes.durationInMillis == 189_000)
        #expect(first.attributes.trackNumber == 4)
        #expect(first.attributes.discNumber == 1)
        #expect(first.attributes.releaseDate == "2021")

        let artworkURL = try #require(first.attributes.artwork?.imageURL())
        #expect(artworkURL.absoluteString.contains("getCoverArt.view"))
        #expect(artworkURL.absoluteString.contains("id=1554079707"))
        #expect(artworkURL.absoluteString.contains("size=%7Bw%7D") == false)
    }

    @Test
    func `search maps live album results`() async throws {
        let session = LiveFixture.makeSession { _ in "search3_test" }
        let service = SubsonicMusicService(
            baseURL: LiveFixture.baseURL,
            username: "user",
            password: "pass",
            session: session,
        )

        let response = try await service.search(
            query: "test",
            type: .album,
            limit: 2,
            offset: 0,
            cacheSearchResponses: false,
            prefetchSongMetadata: false,
        )

        let albums = try #require(response.results.albums)
        #expect(albums.data.count == 2)

        let first = albums.data[0]
        #expect(first.id == "523057413")
        #expect(first.attributes.name == "TwinTail TwinGuitar")
        #expect(first.attributes.artistName == "Hatsune Miku, 海賊王 & [TEST]")
        #expect(first.attributes.genreNames == ["摇滚"])
        #expect(first.attributes.releaseDate == "2012")
    }

    @Test
    func `search maps live artist results`() async throws {
        let session = LiveFixture.makeSession { _ in "search3_test" }
        let service = SubsonicMusicService(
            baseURL: LiveFixture.baseURL,
            username: "user",
            password: "pass",
            session: session,
        )

        let response = try await service.search(
            query: "test",
            type: .artist,
            limit: 2,
            offset: 0,
            cacheSearchResponses: false,
            prefetchSongMetadata: false,
        )

        let artists = try #require(response.results.artists)
        #expect(artists.data.count == 2)

        let second = artists.data[1]
        #expect(second.id == "1071184500")
        #expect(second.attributes.name == "Test")
    }

    @Test
    func `search with no results returns empty lists`() async throws {
        let session = LiveFixture.makeSession { _ in "search3_empty" }
        let service = SubsonicMusicService(
            baseURL: LiveFixture.baseURL,
            username: "user",
            password: "pass",
            session: session,
        )

        let response = try await service.search(
            query: "zzznonexistent",
            type: .song,
            limit: 5,
            offset: 0,
            cacheSearchResponses: false,
            prefetchSongMetadata: false,
        )

        #expect(response.results.songs?.data.isEmpty == true)
        #expect(response.results.albums == nil)
        #expect(response.results.artists == nil)
    }
}

// MARK: - Album

extension LiveFixtureTests {
    @Test
    func `album maps nested track list from live response`() async throws {
        let session = LiveFixture.makeSession { _ in "get_album" }
        let service = SubsonicMusicService(
            baseURL: LiveFixture.baseURL,
            username: "user",
            password: "pass",
            session: session,
        )

        let response = try await service.album(id: "1790412740")
        let album = try #require(response.firstAlbum)

        #expect(album.id == "1790412740")
        #expect(album.attributes.name == "Test for Texture of Text - EP")
        #expect(album.attributes.artistName == "Blume popo")
        #expect(album.attributes.trackCount == 5)
        #expect(album.attributes.genreNames == ["另类音乐"])
        #expect(album.attributes.releaseDate == "2025")

        let tracks = try #require(album.relationships?.tracks)
        #expect(tracks.data.count == 5)

        let firstTrack = tracks.data[0]
        #expect(firstTrack.id == "1790412741")
        #expect(firstTrack.attributes.name == "A bad man had a sad nap. (Album ver.)")
        #expect(firstTrack.attributes.artistName == "Blume popo")
        #expect(firstTrack.attributes.durationInMillis == 217_000)

        let lastTrack = tracks.data[4]
        #expect(lastTrack.attributes.name == "So Low")
        #expect(lastTrack.attributes.durationInMillis == 194_000)

        let artist = try #require(album.relationships?.artists?.data.first)
        #expect(artist.id == "1437859137")
        #expect(artist.attributes.name == "Blume popo")
    }
}

// MARK: - Song

extension LiveFixtureTests {
    @Test
    func `song maps all fields from live response`() async throws {
        let session = LiveFixture.makeSession { _ in "get_song" }
        let service = SubsonicMusicService(
            baseURL: LiveFixture.baseURL,
            username: "user",
            password: "pass",
            session: session,
        )

        let response = try await service.song(id: "258618600")
        let song = try #require(response.firstSong)

        #expect(song.id == "258618600")
        #expect(song.attributes.name == "Test")
        #expect(song.attributes.artistName == "Little Dragon")
        #expect(song.attributes.albumName == "Little Dragon")
        #expect(song.attributes.durationInMillis == 268_000)
        #expect(song.attributes.trackNumber == 10)
        #expect(song.attributes.discNumber == 1)
        #expect(song.attributes.releaseDate == "2007")
        #expect(song.attributes.hasLyrics == true)

        let artwork = try #require(song.attributes.artwork?.imageURL())
        #expect(artwork.absoluteString.contains("getCoverArt.view"))
        #expect(artwork.absoluteString.contains("id=258615649"))
        #expect(artwork.absoluteString.contains("size=%7Bw%7D") == false)

        let albumRel = try #require(song.relationships?.albums?.data.first)
        #expect(albumRel.id == "258615649")

        let artistRel = try #require(song.relationships?.artists?.data.first)
        #expect(artistRel.id == "258535972")
    }
}

// MARK: - Playback

extension LiveFixtureTests {
    @Test
    func `playback assembles stream URL and metadata from live song`() async throws {
        let session = LiveFixture.makeSession { action in
            switch action {
            case "getSong.view": "get_song"
            default: "ping_ok"
            }
        }
        let service = SubsonicMusicService(
            baseURL: LiveFixture.baseURL,
            username: "user",
            password: "pass",
            session: session,
        )

        let info = try await service.playback(id: "258618600")

        let components = try #require(URLComponents(string: info.playbackURL))
        #expect(components.path == "/rest/stream.view")

        let query = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })
        #expect(query["u"] == "user")
        #expect(query["id"] == "258618600")
        #expect(query["t"]?.isEmpty == false)
        #expect(query["s"]?.isEmpty == false)

        #expect(info.codec == "audio/mp4")
        #expect(info.title == "Test")
        #expect(info.artist == "Little Dragon")
        #expect(info.album == "Little Dragon")
        #expect(info.albumID == "258615649")
        #expect(info.artistID == "258535972")
    }
}

// MARK: - Lyrics

extension LiveFixtureTests {
    @Test
    func `lyrics extracts timed text from nested lyrics object`() async throws {
        let session = LiveFixture.makeSession { _ in "get_lyrics" }
        let service = SubsonicMusicService(
            baseURL: LiveFixture.baseURL,
            username: "user",
            password: "pass",
            session: session,
        )

        let response = try await service.lyrics(id: "258618600")
        #expect(response.lyrics.contains("[00:15.32]"))
        #expect(response.lyrics.contains("A test, a test, a test, no rest"))
        #expect(response.lyrics.contains("[03:50.59]"))
        #expect(response.lyrics.contains("Test, test, test, test..."))
    }
}

// MARK: - Errors

extension LiveFixtureTests {
    @Test
    func `not found error surfaces as subsonic business error`() async {
        let session = LiveFixture.makeSession { _ in "error_not_found" }
        let service = SubsonicMusicService(
            baseURL: LiveFixture.baseURL,
            username: "user",
            password: "pass",
            session: session,
        )

        await #expect(throws: APIError.self) {
            try await service.album(id: "nonexistent")
        }
    }

    @Test
    func `auth error code 40 surfaces as subsonic business error`() async {
        let session = LiveFixture.makeSession { _ in "error_auth_failed" }
        let service = SubsonicMusicService(
            baseURL: LiveFixture.baseURL,
            username: "user",
            password: "pass",
            session: session,
        )

        do {
            try await service.ping()
            Issue.record("Expected auth error to be thrown")
        } catch let error as APIError {
            if case let .subsonicRequestFailed(code, message) = error {
                #expect(code == 40)
                #expect(message.contains("wrong username or password"))
            } else {
                Issue.record("Expected subsonicRequestFailed, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
}
