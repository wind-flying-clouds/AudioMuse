//
//  TVNowPlayingView.swift
//  MuseAmpTV
//
//  Root split container for the tvOS Now Playing page.
//  Left half: artwork + transport. Right half: read-only lyrics.
//

import SnapKit
import UIKit

@MainActor
final class TVNowPlayingView: UIView {
    let nowPlayingContentView = TVNowPlayingContentView()
    let lyricsView = TVLyricTimelineView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        let leftContainer = UIView()
        leftContainer.backgroundColor = .clear
        let rightContainer = UIView()
        rightContainer.backgroundColor = .clear

        addSubview(leftContainer)
        addSubview(rightContainer)
        leftContainer.addSubview(nowPlayingContentView)
        rightContainer.addSubview(lyricsView)

        leftContainer.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        rightContainer.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        nowPlayingContentView.snp.makeConstraints { make in
            make.edges
                .equalToSuperview()
                .inset(TVNowPlayingLayout.spacing64 * 2)
        }
        lyricsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}
