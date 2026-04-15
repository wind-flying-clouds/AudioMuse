import ConfigurableKit
import Foundation
@testable import MuseAmp
import MuseAmpDatabaseKit
import Testing

@Suite(.serialized)
struct SearchTextMatcherTests {
    @Test
    func `search matcher matches simplified query against traditional song title`() {
        #expect(SearchTextMatcher.matches("臺灣故事", query: "台湾") == true)
        #expect(SearchTextMatcher.matches("台湾故事", query: "臺灣") == true)
    }

    @Test
    func `search highlight ranges map back to original traditional title`() {
        let ranges = SearchTextMatcher.highlightRanges(in: "臺灣故事", query: "台湾")

        #expect(ranges == [NSRange(location: 0, length: 2)])
    }

    @Test
    func `track title sanitizer strips repeated trailing patterns from back to front`() {
        clearCleanSongTitlePreference()
        defer { clearCleanSongTitlePreference() }

        ConfigurableKit.set(value: true, forKey: AppPreferences.cleanSongTitleKey)
        TrackTitleSanitizer.refresh(titles: [
            "海阔天空 - Single",
            "真的爱你 - Single",
            "喜欢你 [Live]",
            "冷雨夜 [Live]",
            "光辉岁月 (Instrument)",
            "不再犹豫 (Instrument)",
        ])

        #expect("海阔天空 - Single".sanitizedTrackTitle == "海阔天空")
        #expect("喜欢你 [Live] - Single".sanitizedTrackTitle == "喜欢你")
        #expect("光辉岁月 (Instrument) - Single".sanitizedTrackTitle == "光辉岁月")
    }

    @Test
    func `track title sanitizer keeps unique trailing pattern after stripping repeated suffix`() {
        clearCleanSongTitlePreference()
        defer { clearCleanSongTitlePreference() }

        ConfigurableKit.set(value: true, forKey: AppPreferences.cleanSongTitleKey)
        TrackTitleSanitizer.refresh(titles: [
            "海阔天空 - Single",
            "真的爱你 - Single",
            "喜欢你 (Acoustic Session)",
        ])

        #expect("喜欢你 (Acoustic Session) - Single".sanitizedTrackTitle == "喜欢你 (Acoustic Session)")
    }

    @Test
    func `music library search matches simplified and traditional song names`() async throws {
        let sandbox = TestLibrarySandbox()
        let database = try sandbox.makeDatabase()

        _ = try await sandbox.ingestTrack(
            makeMockTrack(
                trackID: "track-tw",
                relativePath: "Beyond/track-tw.m4a",
                title: "臺灣故事",
            ),
            into: database,
        )

        let results = try database.searchTracks(query: "台湾")

        #expect(results.map(\.trackID) == ["track-tw"])
    }
}

private extension SearchTextMatcherTests {
    func clearCleanSongTitlePreference() {
        UserDefaults.standard.removeObject(forKey: AppPreferences.cleanSongTitleKey)
    }
}
