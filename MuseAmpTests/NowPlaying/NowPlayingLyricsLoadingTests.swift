@testable import MuseAmp
import SubsonicClientKit
import Testing

@Suite(.serialized)
struct NowPlayingLyricsLoadingTests {
    @Test
    func `Lyrics 404 responses are cached as unavailable`() {
        #expect(shouldCacheUnavailableLyricsResult(for: APIError.requestFailed(statusCode: 404, serverMessage: nil)))
        #expect(!shouldCacheUnavailableLyricsResult(for: APIError.requestFailed(statusCode: 500, serverMessage: nil)))
        #expect(!shouldCacheUnavailableLyricsResult(for: APIError.invalidResponse))
    }
}
