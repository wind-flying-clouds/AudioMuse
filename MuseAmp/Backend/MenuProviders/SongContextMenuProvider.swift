//
//  SongContextMenuProvider.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/11.
//

import MuseAmpDatabaseKit
import UIKit

final class SongContextMenuProvider {
    enum Context {
        case album
        case downloads
        case library
        case playlist
        case search

        var allowsShowInAlbum: Bool {
            self != .album
        }
    }

    struct Configuration {
        var availablePlaylists: (() -> [Playlist])?
        var onAddToPlaylist: ((UUID) -> Void)?
        var showInAlbum: (() -> Void)?
        var exportItems: (() -> [SongExportItem])?
        var primaryActions: [UIMenuElement] = []
        var libraryActions: [UIMenuElement] = []
        var lyricsActionsBeforeReload: [UIMenuElement] = []
        var secondaryActions: [UIMenuElement] = []
        var destructiveActions: [UIMenuElement] = []
        var includesCopyMenu = true
    }

    private let playlistMenuProvider: AddToPlaylistMenuProvider?
    private let exportPresenter: SongExportPresenter?
    private let lyricsReloadPresenter: LyricsReloadPresenter?

    init(
        playlistMenuProvider: AddToPlaylistMenuProvider? = nil,
        exportPresenter: SongExportPresenter? = nil,
        lyricsReloadPresenter: LyricsReloadPresenter? = nil,
    ) {
        self.playlistMenuProvider = playlistMenuProvider
        self.exportPresenter = exportPresenter
        self.lyricsReloadPresenter = lyricsReloadPresenter
    }

    func menu(
        title: String? = nil,
        for song: PlaylistEntry,
        context: Context,
        configuration: Configuration = .init(),
    ) -> UIMenu? {
        var sections: [UIMenuElement] = []

        // Playback: play, play next, add to queue, like
        if let primarySection = MenuSectionProvider.inline(configuration.primaryActions) {
            sections.append(primarySection)
        }

        // Library: playlist, show in album
        var libraryActions: [UIMenuElement] = []
        if let playlistMenu = makeAddToPlaylistMenu(for: song, configuration: configuration) {
            libraryActions.append(playlistMenu)
        }
        libraryActions.append(contentsOf: configuration.libraryActions)
        if context.allowsShowInAlbum, let showInAlbum = configuration.showInAlbum {
            libraryActions.append(UIAction(
                title: String(localized: "Show in Album"),
                image: UIImage(systemName: "music.note.list"),
            ) { _ in
                showInAlbum()
            })
        }
        if let librarySection = MenuSectionProvider.inline(libraryActions) {
            sections.append(librarySection)
        }

        // Export & Lyrics
        var exportActions: [UIMenuElement] = []
        if let exportAction = makeExportAction(configuration.exportItems) {
            exportActions.append(exportAction)
        }
        if let exportLyricsAction = makeExportLyricsAction(configuration.exportItems) {
            exportActions.append(exportLyricsAction)
        }
        exportActions.append(contentsOf: configuration.lyricsActionsBeforeReload)
        if let reloadLyricsAction = makeReloadLyricsAction(for: song) {
            exportActions.append(reloadLyricsAction)
        }
        if let exportSection = MenuSectionProvider.inline(exportActions) {
            sections.append(exportSection)
        }

        // Copy & Info
        if configuration.includesCopyMenu {
            var copyChildren: [UIMenuElement] = [makeCopyMenu(for: song)]
            copyChildren.append(makeInfoMenu(for: song))
            if let copySection = MenuSectionProvider.inline(copyChildren) {
                sections.append(copySection)
            }
        }

        // Secondary: repair artwork, etc.
        if let secondarySection = MenuSectionProvider.inline(configuration.secondaryActions) {
            sections.append(secondarySection)
        }

        // Destructive: delete, move out
        if let destructiveSection = MenuSectionProvider.inline(configuration.destructiveActions) {
            sections.append(destructiveSection)
        }

        guard !sections.isEmpty else {
            return nil
        }

        if let title {
            return UIMenu(title: title, children: sections)
        }
        return UIMenu(children: sections)
    }
}

private extension SongContextMenuProvider {
    func makeAddToPlaylistMenu(
        for song: PlaylistEntry,
        configuration: Configuration,
    ) -> UIMenu? {
        guard let playlistMenuProvider else {
            return nil
        }

        if let availablePlaylists = configuration.availablePlaylists,
           !availablePlaylists().isEmpty
        {
            return playlistMenuProvider.contextMenu(
                for: [song],
                playlistsProvider: availablePlaylists,
                onAdd: configuration.onAddToPlaylist,
            )
        }

        return playlistMenuProvider.menu(
            for: [song],
            onAdd: configuration.onAddToPlaylist,
        )
    }

    func makeExportAction(_ exportItems: (() -> [SongExportItem])?) -> UIAction? {
        guard let exportItems,
              let exportPresenter
        else {
            return nil
        }

        return UIAction(
            title: String(localized: "Export"),
            image: UIImage(systemName: "square.and.arrow.up"),
        ) { _ in
            let items = exportItems()
            guard !items.isEmpty else { return }
            exportPresenter.present(items: items)
        }
    }

    func makeExportLyricsAction(_ exportItems: (() -> [SongExportItem])?) -> UIAction? {
        guard let exportItems,
              let exportPresenter
        else {
            return nil
        }

        return UIAction(
            title: String(localized: "Export Lyrics"),
            image: UIImage(systemName: "text.quote"),
        ) { _ in
            let items = exportItems()
            guard !items.isEmpty else { return }
            exportPresenter.presentLyricsExport(items: items)
        }
    }

    func makeReloadLyricsAction(for song: PlaylistEntry) -> UIAction? {
        guard let lyricsReloadPresenter else { return nil }
        return UIAction(
            title: String(localized: "Reload Lyrics"),
            image: UIImage(systemName: "arrow.clockwise"),
        ) { _ in
            lyricsReloadPresenter.reloadLyrics(for: song.trackID, title: song.title)
        }
    }

    func makeInfoMenu(for song: PlaylistEntry) -> UIMenu {
        var children: [UIAction] = []

        if let albumID = song.albumID, !albumID.isEmpty {
            children.append(UIAction(
                title: String(localized: "Album") + ": \(albumID)",
                image: UIImage(systemName: "square.stack"),
            ) { _ in
                UIPasteboard.general.string = albumID
            })
        }

        children.append(UIAction(
            title: String(localized: "Song") + ": \(song.trackID)",
            image: UIImage(systemName: "music.note"),
        ) { _ in
            UIPasteboard.general.string = song.trackID
        })

        return UIMenu(
            title: String(localized: "Info"),
            image: UIImage(systemName: "info.circle"),
            children: children,
        )
    }

    func makeCopyMenu(for song: PlaylistEntry) -> UIMenu {
        let copyName = UIAction(
            title: String(localized: "Song Name"),
            subtitle: song.title,
            image: UIImage(systemName: "textformat"),
        ) { _ in
            UIPasteboard.general.string = song.title
        }

        let copyArtist = UIAction(
            title: String(localized: "Artist Name"),
            subtitle: song.artistName,
            image: UIImage(systemName: "person.text.rectangle"),
        ) { _ in
            UIPasteboard.general.string = song.artistName
        }

        var children: [UIMenuElement] = [copyName, copyArtist]
        if let albumName = song.albumTitle, !albumName.isEmpty {
            children.append(UIAction(
                title: String(localized: "Album Name"),
                subtitle: albumName,
                image: UIImage(systemName: "square.stack"),
            ) { _ in
                UIPasteboard.general.string = albumName
            })
        }

        return CopyMenuProvider.menu(children: children)
    }
}
