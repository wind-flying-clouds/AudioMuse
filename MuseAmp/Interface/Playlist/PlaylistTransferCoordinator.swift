import AlertController
import MuseAmpDatabaseKit
import UIKit
import UniformTypeIdentifiers

@MainActor
final class PlaylistTransferCoordinator: NSObject {
    private weak var viewController: UIViewController?
    private let playlistStore: PlaylistStore
    private let environment: AppEnvironment?

    var onImportCompleted: (Playlist) -> Void = { _ in }

    init(
        viewController: UIViewController?,
        playlistStore: PlaylistStore,
        environment: AppEnvironment?,
    ) {
        self.viewController = viewController
        self.playlistStore = playlistStore
        self.environment = environment
    }

    func presentImportPicker() {
        guard let viewController else {
            return
        }

        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [UTType(exportedAs: PlaylistTransferFileType.identifier, conformingTo: .json)],
        )
        picker.delegate = self
        picker.allowsMultipleSelection = false
        viewController.present(picker, animated: true)
    }

    func handleImportedFile(_ url: URL) {
        guard let environment else {
            presentAlert(
                title: String(localized: "Import Failed"),
                message: String(localized: "Playlist import is not available because the local library services are not ready."),
            )
            return
        }

        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let document = try decodeDocument(from: url)
            let playlistName = document.name.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
                ?? String(localized: "Imported Playlist")

            var missingSongs: [PlaylistTransferDocument.SongReference] = []
            let importedEntries = document.songs.compactMap { song -> PlaylistEntry? in
                guard let track = environment.libraryDatabase.trackOrNil(byID: song.trackID) else {
                    missingSongs.append(song)
                    return nil
                }
                return track.playlistEntry
            }

            let playlist = playlistStore.importPlaylist(
                name: playlistName,
                coverImageData: document.coverImageData,
                entries: importedEntries,
            )
            onImportCompleted(playlist)
            presentImportSummary(
                playlist: playlist,
                importedCount: importedEntries.count,
                missingSongs: missingSongs,
            )
        } catch {
            AppLog.error(self, "handleImportedFile failed url=\(url.lastPathComponent) error=\(error)")
            presentAlert(
                title: String(localized: "Import Failed"),
                message: String(localized: "The selected file is not a valid playlist export."),
            )
        }
    }

    func share(
        playlist: Playlist,
        barButtonItem: UIBarButtonItem? = nil,
        sourceView: UIView? = nil,
        sourceRect: CGRect? = nil,
    ) {
        guard let viewController else {
            return
        }

        do {
            let fileURL = try makeExportFile(for: playlist)
            let controller = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            controller.completionWithItemsHandler = { _, _, _, _ in
                self.cleanupExportDirectory(fileURL.deletingLastPathComponent())
            }

            if let popover = controller.popoverPresentationController {
                if let barButtonItem {
                    popover.barButtonItem = barButtonItem
                } else if let resolvedSourceView = sourceView ?? viewController.view {
                    popover.sourceView = resolvedSourceView
                    popover.sourceRect = sourceRect ?? resolvedSourceView.bounds
                }
            }

            viewController.present(controller, animated: true)
        } catch {
            AppLog.error(self, "share failed playlistID=\(playlist.id) error=\(error)")
            presentAlert(
                title: String(localized: "Playlist Sharing Failed"),
                message: error.localizedDescription,
            )
        }
    }
}

extension PlaylistTransferCoordinator: UIDocumentPickerDelegate {
    func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        handleImportedFile(url)
    }
}

private extension PlaylistTransferCoordinator {
    func decodeDocument(from url: URL) throws -> PlaylistTransferDocument {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(PlaylistTransferDocument.self, from: data)
    }

    func makeExportFile(for playlist: Playlist) throws -> URL {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("am-playlist-share-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        let fileURL = directoryURL.appendingPathComponent(
            PlaylistTransferDocument(playlist: playlist).exportFileName,
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(PlaylistTransferDocument(playlist: playlist)).write(to: fileURL)
        return fileURL
    }

    func cleanupExportDirectory(_ directoryURL: URL) {
        do {
            try FileManager.default.removeItem(at: directoryURL)
        } catch {
            AppLog.error(self, "cleanupExportDirectory failed url=\(directoryURL.lastPathComponent) error=\(error)")
        }
    }

    func presentImportSummary(
        playlist: Playlist,
        importedCount: Int,
        missingSongs: [PlaylistTransferDocument.SongReference],
    ) {
        var lines = [String(localized: "Imported \"\(playlist.name)\" with \(importedCount) songs.")]

        if !missingSongs.isEmpty {
            lines.append("")
            lines.append(String(localized: "Missing \(missingSongs.count) songs in this library:"))

            let previewSongs = Array(missingSongs.prefix(8))
            lines.append(contentsOf: previewSongs.map { "- \($0.title) - \($0.artistName)" })

            let remainingCount = missingSongs.count - previewSongs.count
            if remainingCount > 0 {
                lines.append(String(localized: "... and \(remainingCount) more"))
            }
        }

        presentAlert(
            title: String(localized: "Playlist Imported"),
            message: lines.joined(separator: "\n"),
        )
    }

    func presentAlert(title: String, message: String) {
        guard let viewController else {
            return
        }

        let alert = AlertViewController(title: title, message: message) { context in
            context.addAction(title: String(localized: "OK"), attribute: .accent) { context.dispose() }
        }
        viewController.present(alert, animated: true)
    }
}
