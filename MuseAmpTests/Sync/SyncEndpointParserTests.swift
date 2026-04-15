@testable import MuseAmp
import Testing

struct SyncEndpointParserTests {
    @Test
    func `parses hostname and port`() throws {
        let endpoint = try SyncEndpoint.parse("speaker-room.local:52301")
        #expect(endpoint.host == "speaker-room.local")
        #expect(endpoint.port == 52301)
        #expect(endpoint.displayString == "speaker-room.local:52301")
    }

    @Test
    func `parses ipv4 and port`() throws {
        let endpoint = try SyncEndpoint.parse("192.168.1.10:52301")
        #expect(endpoint.host == "192.168.1.10")
        #expect(endpoint.port == 52301)
    }

    @Test
    func `parses bracketed ipv6 and port`() throws {
        let endpoint = try SyncEndpoint.parse("[fd12::12]:52301")
        #expect(endpoint.host == "fd12::12")
        #expect(endpoint.port == 52301)
        #expect(endpoint.displayString == "[fd12::12]:52301")
    }

    @Test
    func `rejects malformed address`() {
        #expect(throws: SyncEndpointParseError.self) {
            _ = try SyncEndpoint.parse("fd12::12:52301")
        }
    }

    @Test
    func `strips IPv6 zone ID from link-local address`() {
        let endpoint = SyncEndpoint(host: "fe80::ca9:c461:bbde:ef0b%en0", port: 61423)
        #expect(endpoint.host == "fe80::ca9:c461:bbde:ef0b")
        #expect(endpoint.url(path: "/auth") != nil)
    }

    @Test
    func `strips IPv6 zone ID from bracketed link-local address`() throws {
        let endpoint = try SyncEndpoint.parse("[fe80::1%en0]:8080")
        #expect(endpoint.host == "fe80::1")
        #expect(endpoint.port == 8080)
        #expect(endpoint.url(path: "/manifest") != nil)
    }

    @Test
    func `preserves global IPv6 address without zone ID`() {
        let endpoint = SyncEndpoint(host: "2409:8a28:f5c:cd10:1cd7:e88:28f5:bd5b", port: 61423)
        #expect(endpoint.host == "2409:8a28:f5c:cd10:1cd7:e88:28f5:bd5b")
        #expect(endpoint.url(path: "/auth") != nil)
    }
}
