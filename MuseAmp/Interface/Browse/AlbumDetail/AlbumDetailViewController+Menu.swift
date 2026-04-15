//
//  AlbumDetailViewController+Menu.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/11.
//

import MuseAmpDatabaseKit
import UIKit

// MARK: - Menu Building

extension AlbumDetailViewController {
    func buildAddMenu() -> UIMenu {
        let downloadAll = makeDownloadAllAction()

        let copyMenu = CopyMenuProvider.albumMenu(
            albumName: album.attributes.name,
            artistName: album.attributes.artistName,
            songNames: tracks.map(\.attributes.name),
        )

        var menuSections: [UIMenuElement] = []
        if let playbackSection = MenuSectionProvider.inline(albumPrimaryPlaybackActions()) {
            menuSections.append(playbackSection)
        }
        menuSections.append(UIMenu(options: .displayInline, children: [downloadAll]))
        let exportActions = makeAlbumExportActions()
        if !exportActions.isEmpty {
            menuSections.append(UIMenu(options: .displayInline, children: exportActions))
        }
        var playlistActions: [UIMenuElement] = [makeSaveAsPlaylistAction()]
        if let saveToPlaylistMenu = makeSaveToPlaylistMenu() {
            playlistActions.append(saveToPlaylistMenu)
        }
        menuSections.append(UIMenu(options: .displayInline, children: playlistActions))
        menuSections.append(UIMenu(options: .displayInline, children: [copyMenu]))
        return UIMenu(children: menuSections)
    }

    func buildTrackMenu(for track: CatalogSong) -> UIMenu {
        let isDownloaded = environment.downloadStore.isDownloaded(trackID: track.id)
        let downloadAction: UIAction? = isDownloaded ? nil : UIAction(
            title: String(localized: "Download"),
            image: UIImage(systemName: "arrow.down.circle"),
        ) { [weak self] _ in
            self?.saveTrackToLibrary(track)
        }

        let entry = track.playlistEntry(
            albumID: album.id,
            albumName: track.attributes.albumName ?? album.attributes.name,
        )
        var primaryActions = trackPrimaryPlaybackActions(for: track)
        if let downloadAction {
            primaryActions.append(downloadAction)
        }

        var destructiveActions: [UIMenuElement] = []
        if isDownloaded {
            destructiveActions.append(UIAction(
                title: String(localized: "Delete Song"),
                image: UIImage(systemName: "trash"),
                attributes: .destructive,
            ) { [weak self] _ in
                self?.confirmDeleteTrack(track)
            })
        }
        var repairAction: UIAction?
        if let localTrack = environment.libraryDatabase.trackOrNil(byID: track.id),
           localTrack.trackID.isCatalogID || localTrack.albumID.isCatalogID
        {
            repairAction = TrackArtworkRepairPresenter.makeMenuAction { [weak self] _ in
                guard let self else { return }
                TrackArtworkRepairPresenter.present(
                    on: self,
                    track: localTrack,
                    repairService: environment.trackArtworkRepairService,
                )
            }
        }

        return songContextMenuProvider.menu(
            for: entry,
            context: .album,
            configuration: .init(
                availablePlaylists: { [weak self] in self?.environment.playlistStore.playlists ?? [] },
                onAddToPlaylist: { [weak self] playlistID in
                    self?.fetchLyricsInBackground(trackIDs: [track.id], playlistID: playlistID)
                },
                exportItems: { [weak self] in
                    guard let item = self?.exportItem(for: track) else { return [] }
                    return [item]
                },
                primaryActions: primaryActions,
                secondaryActions: repairAction.map { [$0] } ?? [],
                destructiveActions: destructiveActions,
            ),
        ) ?? UIMenu(children: primaryActions)
    }

    func albumPrimaryPlaybackActions() -> [UIMenuElement] {
        guard !tracks.isEmpty else { return [] }
        let shufflePlayAction = UIAction(
            title: String(localized: "Shuffle Play"),
            image: UIImage(systemName: "shuffle"),
        ) { [weak self] _ in
            self?.playAlbum(shuffle: true)
        }
        let playNextAction = UIAction(
            title: String(localized: "Play Next"),
            image: UIImage(systemName: "text.insert"),
        ) { [weak self] _ in
            self?.queueDownloadedAlbumTracks(playNext: true)
        }
        let addToQueueAction = UIAction(
            title: String(localized: "Add to Queue"),
            image: UIImage(systemName: "text.append"),
        ) { [weak self] _ in
            self?.queueDownloadedAlbumTracks(playNext: false)
        }

        return [
            UIAction(
                title: String(localized: "Play"),
                image: UIImage(systemName: "play.fill"),
            ) { [weak self] _ in
                self?.playAlbum()
            },
            PlaybackMenuProvider.makePlayAtMenu(children: [shufflePlayAction, playNextAction, addToQueueAction]),
        ]
    }

    func trackPrimaryPlaybackActions(for track: CatalogSong) -> [UIMenuElement] {
        let playbackTrack = track.playbackTrack(apiClient: apiClient)

        let playAction = UIAction(
            title: String(localized: "Play"),
            image: UIImage(systemName: "play.fill"),
        ) { [weak self] _ in
            self?.playAlbumStarting(trackID: track.id)
        }
        let playNextAction = UIAction(
            title: String(localized: "Play Next"),
            image: UIImage(systemName: "text.insert"),
        ) { [weak self] _ in
            self?.queueTrack(playbackTrack, playNext: true)
        }
        let addToQueueAction = UIAction(
            title: String(localized: "Add to Queue"),
            image: UIImage(systemName: "text.append"),
        ) { [weak self] _ in
            self?.queueTrack(playbackTrack, playNext: false)
        }

        return [
            playAction,
            PlaybackMenuProvider.makePlayAtMenu(children: [playNextAction, addToQueueAction]),
            makeLikeAction(for: playbackTrack),
        ]
    }

    func makeLikeAction(for track: PlaybackTrack) -> UIAction {
        let isLiked = environment.playbackController.isLiked(trackID: track.id)
        return UIAction(
            title: isLiked ? String(localized: "Unlike") : String(localized: "Like"),
            image: UIImage(systemName: isLiked ? "heart.slash" : "heart"),
        ) { [weak self] _ in
            _ = self?.environment.playbackController.toggleLiked(track)
        }
    }
}

// MARK: - Menu Support

extension AlbumDetailViewController {
    func makeAlbumExportActions() -> [UIMenuElement] {
        let downloadedItems = tracks.compactMap { exportItem(for: $0) }
        guard !downloadedItems.isEmpty else { return [] }

        let exportAction = UIAction(
            title: String(localized: "Export"),
            image: UIImage(systemName: "square.and.arrow.up"),
        ) { [weak self] _ in
            guard let self else { return }
            let items = tracks.compactMap { self.exportItem(for: $0) }
            songExportPresenter.present(
                items: items,
                barButtonItem: navigationItem.rightBarButtonItem,
            )
        }

        let exportLyricsAction = UIAction(
            title: String(localized: "Export Lyrics"),
            image: UIImage(systemName: "text.quote"),
        ) { [weak self] _ in
            guard let self else { return }
            let items = tracks.compactMap { self.exportItem(for: $0) }
            songExportPresenter.presentLyricsExport(
                items: items,
                barButtonItem: navigationItem.rightBarButtonItem,
            )
        }

        return [exportAction, exportLyricsAction]
    }

    func makeDownloadAllAction() -> UIAction {
        DownloadMenuProvider.downloadAllAction(
            allDownloaded: areAllTracksDownloaded,
        ) { [weak self] in
            self?.saveToLibrary()
        }
    }

    func makeSaveAsPlaylistAction() -> UIAction {
        if tracks.isEmpty {
            return UIAction(
                title: String(localized: "Save as Playlist"),
                image: UIImage(systemName: "plus.rectangle.on.folder"),
                attributes: .disabled,
            ) { _ in }
        }
        return UIAction(
            title: String(localized: "Save as Playlist"),
            image: UIImage(systemName: "plus.rectangle.on.folder"),
        ) { [weak self] _ in
            self?.saveAlbumAsPlaylist()
        }
    }

    func makeSaveToPlaylistMenu() -> UIMenu? {
        guard !environment.playlistStore.playlists.isEmpty else { return nil }

        return playlistMenuProvider.menu(
            songsProvider: { [weak self] in
                self?.playlistEntriesForCurrentTracks() ?? []
            },
            title: String(localized: "Save to Playlist"),
            allowsCreatingPlaylist: false,
        ) { [weak self] playlistID in
            self?.fetchLyricsInBackground(trackIDs: self?.tracks.map(\.id) ?? [], playlistID: playlistID)
        }
    }
}
