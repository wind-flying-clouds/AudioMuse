import ConfigurableKit
import Foundation
@testable import MuseAmp
import Testing

@Suite(.serialized)
struct AppPreferencesTests {
    @Test
    func `Normalize server URL appends rest path and preserves explicit scheme`() {
        #expect(AppPreferences.normalizeSubsonicServerURL("example.com")?.absoluteString == "https://example.com/rest")
        #expect(
            AppPreferences.normalizeSubsonicServerURL("http://example.com/music")?.absoluteString
                == "http://example.com/music/rest",
        )
        #expect(
            AppPreferences.normalizeSubsonicServerURL("https://example.com/rest?x=1")?.absoluteString
                == "https://example.com/rest",
        )
        #expect(AppPreferences.normalizeSubsonicServerURL("   ") == nil)
    }

    @Test
    func `Current Subsonic configuration trims stored values`() {
        clearPreferences()
        defer { clearPreferences() }

        ConfigurableKit.set(value: " https://demo.example.com ", forKey: AppPreferences.subsonicServerURLKey)
        ConfigurableKit.set(value: "  alice  ", forKey: AppPreferences.subsonicUsernameKey)
        ConfigurableKit.set(value: "  secret  ", forKey: AppPreferences.subsonicPasswordKey)

        let configuration = AppPreferences.currentSubsonicConfiguration
        #expect(configuration?.baseURL.absoluteString == "https://demo.example.com/rest")
        #expect(configuration?.username == "alice")
        #expect(configuration?.password == "secret")
    }

    @Test
    func `APIClient picks up updated configured Subsonic profile`() throws {
        clearPreferences()
        defer { clearPreferences() }

        let fallbackURL = try #require(URL(string: "https://fallback.example.com/rest"))
        let client = APIClient(baseURL: fallbackURL)

        #expect(client.baseURL.host == "fallback.example.com")

        try AppPreferences.setSubsonicConfiguration(
            SubsonicConfiguration(
                baseURL: #require(URL(string: "http://music.example.com/rest")),
                username: "demo",
                password: "secret",
            ),
        )

        #expect(client.baseURL.host == "music.example.com")
        #expect(client.baseURL.scheme == "http")

        AppPreferences.clearSubsonicConfiguration()

        #expect(client.baseURL.host == "fallback.example.com")
    }
}

private extension AppPreferencesTests {
    func clearPreferences() {
        UserDefaults.standard.removeObject(forKey: AppPreferences.subsonicServerURLKey)
        UserDefaults.standard.removeObject(forKey: AppPreferences.subsonicUsernameKey)
        UserDefaults.standard.removeObject(forKey: AppPreferences.subsonicPasswordKey)
    }
}
