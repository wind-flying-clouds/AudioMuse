# MuseAmp

MuseAmp is a UIKit music client and local library runtime for iPhone, Mac Catalyst, and Apple TV. The project combines local library indexing, downloaded audio playback, playlists, lyrics, Subsonic-backed catalog access, and LAN sync in one codebase.

## Highlights

- Local-first library runtime backed by `MuseAmpDatabaseKit`
- Queue-based playback powered by `MuseAmpPlayerKit`
- Playlist management with a built-in liked songs playlist
- Download persistence, metadata embedding, and launch reconciliation
- Lyrics caching, reload, and timeline parsing
- Local and remote search flows
- LAN sync between devices, including Apple TV handoff support
- Subsonic catalog, album, song, lyrics, and playback metadata integration

**Muse Amp does not support streaming playback.** All tracks must be downloaded to the device before they can be played. The app's Subsonic integration focuses on catalog browsing and metadata access, not streaming.

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
