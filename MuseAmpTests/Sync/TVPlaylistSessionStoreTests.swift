import Foundation
@testable import MuseAmp
import MuseAmpDatabaseKit
import Testing

@Suite(.serialized)
struct TVPlaylistSessionStoreTests {
    @Test
    func `session store round-trips and validates a complete transferred playlist session`() async throws {
        let sandbox = TestLibrarySandbox()
        let database = try sandbox.makeDatabase()

        _ = try await sandbox.ingestTrack(
            makeMockTrack(trackID: "track-a", relativePath: "TVAlbum/track-a.m4a", title: "Track A"),
            into: database,
        )
        _ = try await sandbox.ingestTrack(
            makeMockTrack(trackID: "track-b", relativePath: "TVAlbum/track-b.m4a", title: "Track B"),
            into: database,
        )

        let fileURL = sandbox.baseDirectory.appendingPathComponent("tv-playlist-session.json", isDirectory: false)
        let store = TVPlaylistSessionStore(fileURL: fileURL)
        let manifest = makeManifest(orderedTrackIDs: ["track-a", "track-b", "track-a"])

        store.save(manifest)

        #expect(store.load() == manifest)

        let validation = store.validate(database: database, paths: database.paths)
        guard case let .valid(restoredManifest) = validation else {
            Issue.record("Expected valid session, got \(validation)")
            return
        }

        #expect(restoredManifest == manifest)
        #expect(restoredManifest.orderedTrackIDs == ["track-a", "track-b", "track-a"])
        #expect(restoredManifest.expectedTrackCount == 3)
        #expect(restoredManifest.expectedUniqueTrackCount == 2)
    }

    @Test
    func `session store reports invalid when Apple TV audio files were cleaned`() async throws {
        let sandbox = TestLibrarySandbox()
        let database = try sandbox.makeDatabase()

        let ingested = try await sandbox.ingestTrack(
            makeMockTrack(trackID: "track-a", relativePath: "TVAlbum/track-a.m4a", title: "Track A"),
            into: database,
        )

        let fileURL = sandbox.baseDirectory.appendingPathComponent("tv-playlist-session.json", isDirectory: false)
        let store = TVPlaylistSessionStore(fileURL: fileURL)
        store.save(makeManifest(orderedTrackIDs: [ingested.trackID]))

        let audioURL = database.paths.absoluteAudioURL(for: ingested.relativePath)
        try FileManager.default.removeItem(at: audioURL)

        let validation = store.validate(database: database, paths: database.paths)
        guard case let .invalid(message) = validation else {
            Issue.record("Expected invalid session, got \(validation)")
            return
        }

        #expect(message.contains("Apple TV"))
        #expect(!message.isEmpty)
    }
}

private extension TVPlaylistSessionStoreTests {
    func makeManifest(
        orderedTrackIDs: [String],
        sessionID: String = "tv-session-1",
    ) -> TVPlaylistSessionManifest {
        let syncSession = SyncPlaylistSession(
            playlistName: "Living Room Playlist",
            sessionID: sessionID,
            orderedTrackIDs: orderedTrackIDs,
            createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            updatedAt: Date(timeIntervalSince1970: 1_700_000_100),
        )
        return TVPlaylistSessionManifest(syncSession: syncSession, sourceDeviceName: "iPhone")
    }
}
