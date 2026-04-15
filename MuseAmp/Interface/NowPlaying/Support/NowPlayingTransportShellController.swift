//
//  NowPlayingTransportShellController.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/11.
//

// Kept as an empty marker protocol for controllers that host a
// NowPlayingTransportView. The view now owns its own subscription to
// environment.playbackController, so no push-based wiring is required here.

@MainActor
protocol NowPlayingTransportShellController: NowPlayingPlaybackShellController {}
