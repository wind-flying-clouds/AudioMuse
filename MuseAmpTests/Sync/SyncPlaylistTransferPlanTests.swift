import Foundation
@testable import MuseAmp
import MuseAmpDatabaseKit
import Testing

@Suite(.serialized)
struct SyncPlaylistTransferPlanTests {
    @Test
    func `playlist transfer plan preserves playlist order while only exporting locally available tracks`() async throws {
        let sandbox = TestLibrarySandbox()
        let database = try sandbox.makeDatabase()

        _ = try await sandbox.ingestTrack(
            makeMockTrack(trackID: "track-a", relativePath: "AlbumA/track-a.m4a", title: "Track A"),
            into: database,
        )
        _ = try await sandbox.ingestTrack(
            makeMockTrack(trackID: "track-b", relativePath: "AlbumB/track-b.m4a", title: "Track B"),
            into: database,
        )

        let playlist = Playlist(
            name: "Road Trip",
            entries: [
                PlaylistEntry(trackID: "track-a", title: "Track A", artistName: "Artist"),
                PlaylistEntry(trackID: "missing-track", title: "Missing", artistName: "Artist"),
                PlaylistEntry(trackID: "track-b", title: "Track B", artistName: "Artist"),
                PlaylistEntry(trackID: "track-a", title: "Track A Again", artistName: "Artist"),
            ],
        )

        let plan = try #require(
            SyncPlaylistTransferPlan(
                playlist: playlist,
                database: database,
                paths: database.paths,
            ),
        )

        #expect(plan.transferableTracks.map(\.trackID) == ["track-a", "track-b"])
        #expect(plan.skippedTrackIDs == ["missing-track"])
        #expect(plan.session.playlistName == "Road Trip")
        #expect(plan.session.orderedTrackIDs == ["track-a", "track-b", "track-a"])
        #expect(plan.session.expectedTrackCount == 3)
        #expect(plan.session.expectedUniqueTrackCount == 2)
    }

    @Test
    func `direct tracks transfer plan creates a valid session with all track IDs`() {
        let tracks = [
            makeMockTrack(trackID: "track-1", relativePath: "A/track-1.m4a", title: "Song 1"),
            makeMockTrack(trackID: "track-2", relativePath: "B/track-2.m4a", title: "Song 2"),
            makeMockTrack(trackID: "track-3", relativePath: "C/track-3.m4a", title: "Song 3"),
        ]

        let plan = SyncPlaylistTransferPlan(
            transferableTracks: tracks,
            totalTrackCount: tracks.count,
        )

        #expect(plan.transferableTracks.count == 3)
        #expect(plan.skippedTrackIDs.isEmpty)
        #expect(plan.session.orderedTrackIDs == ["track-1", "track-2", "track-3"])
        #expect(plan.session.expectedTrackCount == 3)
        #expect(!plan.session.playlistName.isEmpty)
    }

    @Test
    func `playlist transfer plan is nil when no playlist tracks resolve to local files`() throws {
        let sandbox = TestLibrarySandbox()
        let database = try sandbox.makeDatabase()
        let playlist = Playlist(
            name: "Empty",
            entries: [
                PlaylistEntry(trackID: "missing-track", title: "Missing", artistName: "Artist"),
            ],
        )

        let plan = SyncPlaylistTransferPlan(
            playlist: playlist,
            database: database,
            paths: database.paths,
        )

        #expect(plan == nil)
    }
}
