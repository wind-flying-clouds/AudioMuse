//
//  NowPlayingCompactPageController.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/11.
//

import AVKit
import MuseAmpPlayerKit
import SnapKit
import UIKit

final class NowPlayingCompactPageController: UIViewController {
    private let listSectionView = NowPlayingListSectionView()
    private let compactTransportView: NowPlayingCompactTransportView
    private lazy var centerSectionView = NowPlayingCenterSectionView(
        environment: environment,
        transportContentView: compactTransportView,
        transportLayout: .fullWidth(inset: 16),
    )
    let lyricTimelineView: LyricTimelineView
    private lazy var pagingSectionView = NowPlayingPagingSectionView(
        queueView: listSectionView,
        artworkView: centerSectionView,
        lyricsView: lyricTimelineView,
    )

    private let environment: AppEnvironment

    init(environment: AppEnvironment) {
        self.environment = environment
        compactTransportView = NowPlayingCompactTransportView(environment: environment)
        lyricTimelineView = LyricTimelineView(environment: environment)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    var onPageChanged: (NowPlayingControlIslandViewModel.ContentSelector) -> Void = { _ in }

    var onLyricTapped: () -> Void = {} {
        didSet {
            compactTransportView.onLyricTapped = onLyricTapped
        }
    }

    var onToggleQueueShuffle: () -> Void = {} {
        didSet {
            listSectionView.onToggleShuffle = onToggleQueueShuffle
        }
    }

    var onCycleQueueRepeatMode: () -> Void = {} {
        didSet {
            listSectionView.onCycleRepeatMode = onCycleQueueRepeatMode
        }
    }

    var onSelectQueueTrack: (NowPlayingQueueTrackSelection) -> Void = { _ in } {
        didSet {
            listSectionView.onSelectQueueTrack = onSelectQueueTrack
        }
    }

    var onRemoveQueueTrack: (Int) -> Void = { _ in } {
        didSet {
            listSectionView.onRemoveQueueTrack = onRemoveQueueTrack
        }
    }

    var onRestartCurrentTrack: () -> Void = {} {
        didSet {
            listSectionView.onRestartCurrentTrack = onRestartCurrentTrack
        }
    }

    var onPlayFromHere: (Int) -> Void = { _ in } {
        didSet {
            listSectionView.onPlayFromHere = onPlayFromHere
        }
    }

    var onPlayNext: (Int) -> Void = { _ in } {
        didSet {
            listSectionView.onPlayNext = onPlayNext
        }
    }

    var onArtworkLoaded: (URL, UIImage) -> Void = { _, _ in } {
        didSet {
            centerSectionView.onArtworkLoaded = onArtworkLoaded
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        installPagingSectionView()
        installAuxiliaryView()
    }

    func installRoutePickerView(_ routePickerView: AVRoutePickerView) {
        compactTransportView.installRoutePickerView(routePickerView)
    }

    func setSelector(
        _ selector: NowPlayingControlIslandViewModel.ContentSelector,
        animated: Bool,
    ) {
        pagingSectionView.setSelector(selector, animated: animated)
    }

    func updateQueue(
        queue: [PlaybackTrack],
        playerIndex: Int?,
        repeatMode: RepeatMode,
    ) {
        listSectionView.updateQueue(
            queue: queue,
            playerIndex: playerIndex,
            repeatMode: repeatMode,
        )
    }

    func setQueueShuffleFeedbackActive(_ isActive: Bool) {
        listSectionView.setShuffleFeedbackActive(isActive)
    }

    func updateCurrentLyricLine(_ line: String?) {
        compactTransportView.updateCurrentLyricLine(line)
    }

    func updateTransportSongMenu(_ menu: UIMenu?) {
        compactTransportView.setSongMenu(menu)
    }

    func setInterfaceSuspended(_ suspended: Bool) {
        compactTransportView.setAnimationsSuspended(suspended)
    }

    func ensureCurrentPageIsLaidOut() {
        pagingSectionView.ensureCurrentPageIsLaidOut()
    }

    private func installAuxiliaryView() {
        let auxiliaryView = compactTransportView.auxiliaryContainerView
        view.addSubview(auxiliaryView)
        auxiliaryView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(44)
        }
    }

    private func installPagingSectionView() {
        pagingSectionView.onPageChanged = { [weak self] selector in
            self?.onPageChanged(selector)
        }
        pagingSectionView.onArtworkPageDistance = { [weak self] distance in
            self?.updateAuxiliaryVisibility(artworkDistance: distance)
        }
        view.addSubview(pagingSectionView)
        pagingSectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func updateAuxiliaryVisibility(artworkDistance: CGFloat) {
        let auxiliaryView = compactTransportView.auxiliaryContainerView
        let clamped = max(0, min(1, artworkDistance))
        auxiliaryView.alpha = 1 - clamped
        auxiliaryView.isUserInteractionEnabled = clamped < 0.01
    }
}
