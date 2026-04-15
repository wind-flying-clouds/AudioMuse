import Foundation
@testable import MuseAmp
import MuseAmpDatabaseKit
import Testing

@Suite(.serialized)
@MainActor
struct PlaylistStoreTests {
    private func makeTempStore() throws -> (TestLibrarySandbox, PlaylistStore) {
        let sandbox = TestLibrarySandbox()
        let database = try sandbox.makeDatabase()
        let store = PlaylistStore(database: database)
        return (sandbox, store)
    }

    private func userPlaylists(in store: PlaylistStore) -> [Playlist] {
        store.playlists.filter { $0.id != Playlist.likedSongsPlaylistID }
    }

    @Test
    func `Create playlist adds to store`() throws {
        let (_, store) = try makeTempStore()
        let playlist = store.createPlaylist(name: "My Playlist")

        #expect(userPlaylists(in: store).count == 1)
        #expect(playlist.name == "My Playlist")
        #expect(playlist.songs.isEmpty)
    }

    @Test
    func `Delete playlist removes from store`() throws {
        let (_, store) = try makeTempStore()
        let playlist = store.createPlaylist(name: "To Delete")
        store.deletePlaylist(id: playlist.id)

        #expect(userPlaylists(in: store).isEmpty)
    }

    @Test
    func `Delete playlists removes selected playlists from store`() throws {
        let (_, store) = try makeTempStore()
        let first = store.createPlaylist(name: "First")
        _ = store.createPlaylist(name: "Second")
        let third = store.createPlaylist(name: "Third")

        store.deletePlaylists(ids: [first.id, third.id])

        #expect(userPlaylists(in: store).count == 1)
        #expect(userPlaylists(in: store).first?.name == "Second")
    }

    @Test
    func `Rename playlist updates name`() throws {
        let (_, store) = try makeTempStore()
        let playlist = store.createPlaylist(name: "Old Name")
        store.renamePlaylist(id: playlist.id, name: "New Name")

        #expect(store.playlist(for: playlist.id)?.name == "New Name")
    }

    @Test
    func `Add song to playlist`() throws {
        let (_, store) = try makeTempStore()
        let playlist = store.createPlaylist(name: "Songs")
        let song = PlaylistEntry(trackID: "123", title: "Test Song", artistName: "Artist", artworkURL: nil)

        store.addSong(song, to: playlist.id)

        #expect(store.playlist(for: playlist.id)?.songs.count == 1)
        #expect(store.playlist(for: playlist.id)?.songs.first?.title == "Test Song")
    }

    @Test
    func `Adding duplicate song creates another playlist entry`() throws {
        let (_, store) = try makeTempStore()
        let playlist = store.createPlaylist(name: "Songs")
        let song = PlaylistEntry(trackID: "123", title: "Test Song", artistName: "Artist", artworkURL: nil)

        store.addSong(song, to: playlist.id)
        store.addSong(song, to: playlist.id)

        #expect(store.playlist(for: playlist.id)?.songs.count == 2)
        #expect(store.playlist(for: playlist.id)?.songs.map(\.trackID) == ["123", "123"])
    }

    @Test
    func `Remove song from playlist`() throws {
        let (_, store) = try makeTempStore()
        let playlist = store.createPlaylist(name: "Songs")
        let song = PlaylistEntry(trackID: "123", title: "Test", artistName: "A", artworkURL: nil)
        store.addSong(song, to: playlist.id)

        store.removeSong(at: 0, from: playlist.id)

        #expect(store.playlist(for: playlist.id)?.songs.isEmpty == true)
    }

    @Test
    func `Move song reorders playlist`() throws {
        let (_, store) = try makeTempStore()
        let playlist = store.createPlaylist(name: "Songs")
        store.addSong(PlaylistEntry(trackID: "1", title: "A", artistName: "X", artworkURL: nil), to: playlist.id)
        store.addSong(PlaylistEntry(trackID: "2", title: "B", artistName: "X", artworkURL: nil), to: playlist.id)
        store.addSong(PlaylistEntry(trackID: "3", title: "C", artistName: "X", artworkURL: nil), to: playlist.id)

        store.moveSong(in: playlist.id, from: 2, to: 0)

        let names = store.playlist(for: playlist.id)?.songs.map(\.title)
        #expect(names == ["C", "A", "B"])
    }

    @Test
    func `Persistence round-trip preserves data`() throws {
        let sandbox = TestLibrarySandbox()
        let database = try sandbox.makeDatabase()

        let store1 = PlaylistStore(database: database)
        let playlist = store1.createPlaylist(name: "Persisted")
        store1.addSong(
            PlaylistEntry(trackID: "42", title: "Saved Song", artistName: "Saved Artist", artworkURL: nil),
            to: playlist.id,
        )

        let store2 = PlaylistStore(database: database)
        let userPlaylists2 = store2.playlists.filter { $0.id != Playlist.likedSongsPlaylistID }
        #expect(userPlaylists2.count == 1)
        #expect(userPlaylists2.first?.name == "Persisted")
        #expect(userPlaylists2.first?.songs.first?.title == "Saved Song")
    }

    @Test
    func `Import playlist persists provided cover and entries`() throws {
        let (_, store) = try makeTempStore()

        let playlist = store.importPlaylist(
            name: "Imported",
            coverImageData: Data([0x0A, 0x0B]),
            entries: [
                PlaylistEntry(
                    trackID: "track-1",
                    title: "Imported Song",
                    artistName: "Artist",
                    albumID: "album-1",
                    albumTitle: "Album",
                    durationMillis: 90000,
                    trackNumber: 3,
                ),
            ],
        )

        #expect(store.playlist(for: playlist.id)?.name == "Imported")
        #expect(store.playlist(for: playlist.id)?.coverImageData == Data([0x0A, 0x0B]))
        #expect(store.playlist(for: playlist.id)?.songs.map(\.trackID) == ["track-1"])
        #expect(store.playlist(for: playlist.id)?.songs.first?.durationMillis == 90000)
        #expect(store.playlist(for: playlist.id)?.songs.first?.trackNumber == 3)
    }

    @Test
    func `Liked toggle adds song to liked playlist`() throws {
        let (_, store) = try makeTempStore()
        let song = PlaylistEntry(trackID: "liked-track", title: "Liked Track", artistName: "Artist", artworkURL: nil)

        #expect(store.likedSongsPlaylist() != nil)
        #expect(store.likedSongsPlaylist()?.songs.isEmpty == true)
        #expect(store.isLiked(trackID: song.trackID) == false)
        #expect(store.toggleLiked(song) == .liked)
        #expect(store.isLiked(trackID: song.trackID) == true)

        let playlist = store.likedSongsPlaylist()
        #expect(playlist?.id == Playlist.likedSongsPlaylistID)
        #expect(playlist?.coverImageData != nil)
        #expect(playlist?.songs.map(\.trackID) == [song.trackID])
    }

    @Test
    func `Liked toggle deletes liked playlist when last song is removed`() throws {
        let (_, store) = try makeTempStore()
        let song = PlaylistEntry(trackID: "missing-liked", title: "Missing", artistName: "Artist", artworkURL: nil)

        #expect(store.toggleLiked(song) == .liked)
        #expect(store.likedSongsPlaylist() != nil)
        #expect(store.toggleLiked(song) == .unliked)
        #expect(store.likedSongsPlaylist() == nil)
        #expect(store.isLiked(trackID: song.trackID) == false)
    }

    @Test
    func `Removing last song from liked playlist deletes the playlist`() throws {
        let (_, store) = try makeTempStore()
        let song = PlaylistEntry(trackID: "liked-song", title: "Song", artistName: "Artist", artworkURL: nil)

        #expect(store.toggleLiked(song) == .liked)
        let playlist = store.likedSongsPlaylist()
        #expect(playlist?.songs.count == 1)

        if let playlist {
            store.removeSong(at: 0, from: playlist.id)
        }

        #expect(store.likedSongsPlaylist() == nil)
        #expect(store.isLiked(trackID: song.trackID) == false)
    }
}
