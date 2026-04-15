import Foundation
@testable import MuseAmp
import MuseAmpDatabaseKit
import MuseAmpPlayerKit
import Testing

@Suite(.serialized)
@MainActor
struct PlaybackControllerRemoveTracksTests {
    @Test
    func `removeTracksFromQueue removes upcoming track`() async throws {
        let (controller, tracks) = try await makeControllerPlaying(trackCount: 3)
        #expect(controller.latestSnapshot.upcoming.count == 2)

        controller.removeTracksFromQueue(trackIDs: [tracks[1].id])

        #expect(controller.latestSnapshot.upcoming.map(\.id) == [tracks[2].id])
        #expect(controller.latestSnapshot.currentTrack?.id == tracks[0].id)
    }

    @Test
    func `removeTracksFromQueue removes multiple upcoming tracks`() async throws {
        let (controller, tracks) = try await makeControllerPlaying(trackCount: 4)
        #expect(controller.latestSnapshot.upcoming.count == 3)

        controller.removeTracksFromQueue(trackIDs: [tracks[1].id, tracks[3].id])

        #expect(controller.latestSnapshot.upcoming.map(\.id) == [tracks[2].id])
        #expect(controller.latestSnapshot.currentTrack?.id == tracks[0].id)
    }

    @Test
    func `removeTracksFromQueue skips current track when upcoming exists`() async throws {
        let (controller, tracks) = try await makeControllerPlaying(trackCount: 3)
        #expect(controller.latestSnapshot.currentTrack?.id == tracks[0].id)

        controller.removeTracksFromQueue(trackIDs: [tracks[0].id])

        #expect(controller.latestSnapshot.currentTrack?.id == tracks[1].id)
    }

    @Test
    func `removeTracksFromQueue stops playback when current track is only track`() async throws {
        let (controller, tracks) = try await makeControllerPlaying(trackCount: 1)
        #expect(controller.latestSnapshot.currentTrack?.id == tracks[0].id)
        #expect(controller.latestSnapshot.state.isActive)

        controller.removeTracksFromQueue(trackIDs: [tracks[0].id])

        #expect(controller.latestSnapshot.state == .idle)
    }

    @Test
    func `removeTracksFromQueue removes current and upcoming tracks together`() async throws {
        let (controller, tracks) = try await makeControllerPlaying(trackCount: 3)

        controller.removeTracksFromQueue(trackIDs: [tracks[0].id, tracks[1].id])

        #expect(controller.latestSnapshot.currentTrack?.id == tracks[2].id)
    }

    @Test
    func `removeTracksFromQueue with empty set is no-op`() async throws {
        let (controller, tracks) = try await makeControllerPlaying(trackCount: 2)

        controller.removeTracksFromQueue(trackIDs: [])

        #expect(controller.latestSnapshot.currentTrack?.id == tracks[0].id)
        #expect(controller.latestSnapshot.upcoming.count == 1)
    }

    @Test
    func `removeTracksFromQueue with unknown IDs is no-op`() async throws {
        let (controller, tracks) = try await makeControllerPlaying(trackCount: 2)

        controller.removeTracksFromQueue(trackIDs: ["nonexistent-id"])

        #expect(controller.latestSnapshot.currentTrack?.id == tracks[0].id)
        #expect(controller.latestSnapshot.upcoming.count == 1)
    }

    // MARK: - Helpers

    private func makeControllerPlaying(trackCount: Int) async throws -> (PlaybackController, [PlaybackTrack]) {
        let sandbox = TestLibrarySandbox()
        let locations = LibraryPaths(baseDirectory: sandbox.baseDirectory)
        try locations.ensureDirectoriesExist()
        let database = try sandbox.makeDatabase()
        let downloadStore = DownloadStore(database: database, paths: locations)
        let playlistStore = PlaylistStore(database: database)
        let apiClient = try APIClient(baseURL: #require(URL(string: "https://example.com")))

        let controller = PlaybackController(
            apiClient: apiClient,
            database: database,
            downloadStore: downloadStore,
            metadataReader: EmbeddedMetadataReader(),
            paths: locations,
            playlistStore: playlistStore,
        )

        var tracks: [PlaybackTrack] = []
        for i in 0 ..< trackCount {
            let url = try makeLocalAudioFile(
                locations: locations,
                relativePath: "Artist/Album/Track\(i).wav",
            )
            tracks.append(PlaybackTrack(
                id: "track-\(i)",
                title: "Track \(i)",
                artistName: "Artist",
                localFileURL: url,
            ))
        }

        let started = await controller.play(tracks: tracks, source: .library)
        #expect(started == true)

        return (controller, tracks)
    }

    private func makeLocalAudioFile(
        locations: LibraryPaths,
        relativePath: String,
    ) throws -> URL {
        let fileURL = locations.absoluteAudioURL(for: relativePath)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
        )
        try makeSilentWAVData().write(to: fileURL)
        return fileURL
    }

    private func makeSilentWAVData(
        sampleRate: UInt32 = 8000,
        duration: TimeInterval = 30,
    ) -> Data {
        let channelCount: UInt16 = 1
        let bitsPerSample: UInt16 = 16
        let bytesPerSample = UInt32(bitsPerSample / 8)
        let frameCount = UInt32(max(Int((Double(sampleRate) * duration).rounded()), 1))
        let byteRate = sampleRate * UInt32(channelCount) * bytesPerSample
        let blockAlign = channelCount * UInt16(bytesPerSample)
        let dataSize = frameCount * UInt32(blockAlign)
        let riffChunkSize = 36 + dataSize

        var data = Data()
        data.append("RIFF".data(using: .ascii)!)
        data.append(littleEndianBytes(riffChunkSize))
        data.append("WAVE".data(using: .ascii)!)
        data.append("fmt ".data(using: .ascii)!)
        data.append(littleEndianBytes(UInt32(16)))
        data.append(littleEndianBytes(UInt16(1)))
        data.append(littleEndianBytes(channelCount))
        data.append(littleEndianBytes(sampleRate))
        data.append(littleEndianBytes(byteRate))
        data.append(littleEndianBytes(blockAlign))
        data.append(littleEndianBytes(bitsPerSample))
        data.append("data".data(using: .ascii)!)
        data.append(littleEndianBytes(dataSize))
        data.append(Data(count: Int(dataSize)))
        return data
    }

    private func littleEndianBytes<T: FixedWidthInteger>(_ value: T) -> Data {
        var littleEndianValue = value.littleEndian
        return Data(bytes: &littleEndianValue, count: MemoryLayout<T>.size)
    }
}
