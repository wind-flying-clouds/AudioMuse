# MuseAmp

MuseAmp is a local-first music player for people who keep their own music library. Play downloaded songs, manage playlists, browse albums, read synced lyrics, and search across local and remote catalog sources in one focused app.

Connect a Subsonic-compatible server to browse catalog data, fetch artwork and lyrics, and manage the music you want on your device. MuseAmp is designed around downloaded playback, so your library stays available on your terms.

Use MuseAmp to:

- play downloaded music with a queue-based listening experience
- build and organize playlists
- view cached and synced lyrics
- search your library and connected server catalog
- transfer songs across your local network, including Apple TV handoff

MuseAmp keeps your music workflow simple, personal, and local-first.

Imported music currently supports `m4a` only, and the files must be exported from MuseAmp before they can be imported again. Broader format support is planned for a future update.

## Subsonic Compatibility

MuseAmp currently supports a strict Subsonic API subset for download and rebuild workflows.

The upstream Subsonic API treats media IDs as strings. MuseAmp currently uses a stricter catalog contract so the server profile has to match MuseAmp's expectations.

- album IDs and track IDs must be pure numeric strings
- downloadable audio returned by `/rest/stream.view` and `/rest/download.view` must already be `m4a`
- song payloads should expose `suffix=m4a` and `contentType=audio/mp4`
- the bytes returned by `/rest/stream.view` and `/rest/download.view` should match the advertised `m4a` metadata so local ingest, metadata embedding, and rebuild can succeed

Servers that follow the broader Subsonic specification can still fall outside MuseAmp's supported subset. A compatibility layer or a stricter upstream server profile is required for reliable use.

## Project Layout

- `MuseAmp/` — iOS and Mac Catalyst app target
- `MuseAmpTV/` — tvOS shell target
- `MuseAmpDatabaseKit/` — local database, ingest, downloads, playlists, audit data
- `MuseAmpPlayerKit/` — queue and playback engine integration
- `SubsonicClientKit/` — remote music service integration
- `Configuration/` — shared Xcode build configuration
- `MuseAmpTests/` — app-level tests

## Requirements

**To use Muse Amp, you need:**

- iOS/iPadOS 16.0 or newer
- macOS 13.0 or newer (for Catalyst)
- tvOS 17.0 or newer

**To build and test the repository, you need:**

- Xcode 26.3 or newer
- iOS and tvOS SDKs that match the project settings
- Swift Package Manager support through Xcode

## Build And Test

The repository uses the top-level `Makefile` for all build and test workflows.

```bash
make build
make build-ios
make build-catalyst
make build-tvos
make test
make test-unit
make format
make format-lint
make strip-xcstrings
make validate-xcstrings
```

`make test` builds every platform target and then runs the Catalyst test suite. `make test-unit` runs the test suite directly on Mac Catalyst.

## License

Muse Amp is licensed under the MIT License. See `LICENSE` for details.

The repository bundles third-party dependencies whose notices are collected in `MuseAmp/Resources/OpenSourceLicenses.md` and `MuseAmpTV/Resources/OpenSourceLicenses.md`.
