import Foundation
@testable import MuseAmp
import Testing

@Suite(.serialized)
struct TrackArtworkRepairServiceTests {
    @Test
    func `embedded artwork url parses from export comment json`() {
        let comment = #"{"albumID":"456","artworkURL":"https://example.com/artwork.jpg","trackID":"123","v":1}"#

        let artworkURL = TrackArtworkRepairService.embeddedArtworkURL(fromComment: comment)

        #expect(artworkURL?.absoluteString == "https://example.com/artwork.jpg")
    }

    @Test
    func `embedded artwork url ignores invalid payload`() {
        #expect(TrackArtworkRepairService.embeddedArtworkURL(fromComment: "not-json") == nil)
    }

    @Test
    func `embedded artwork url ignores empty field`() {
        let comment = #"{"albumID":"456","artworkURL":" ","trackID":"123","v":1}"#

        #expect(TrackArtworkRepairService.embeddedArtworkURL(fromComment: comment) == nil)
    }
}
