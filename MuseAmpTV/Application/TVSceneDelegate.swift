//
//  TVSceneDelegate.swift
//  MuseAmpTV
//
//  Created by @Lakr233 on 2026/04/11.
//

import Combine
import MuseAmpPlayerKit
import UIKit

@objc(TVSceneDelegate)
final class TVSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var context: TVAppContext?
    private var cancellables: Set<AnyCancellable> = []
    private var isSceneActive = false

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions,
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            AppLog.warning(
                self,
                "Scene is not a UIWindowScene (actual type: \(type(of: scene))) - aborting TV window setup",
            )
            return
        }

        let window = UIWindow(windowScene: windowScene)
        window.tintColor = .white

        let bootController = TVBootProgressController()
        bootController.onBootComplete = { [weak self, weak window] context in
            guard let self, let window else { return }
            self.context = context
            bindPlaybackActivityHold(using: context)
            let rootController = TVRootViewController(context: context)
            rootController.loadViewIfNeeded()
            UIView.transition(
                with: window,
                duration: 0.35,
                options: [.transitionCrossDissolve, .beginFromCurrentState, .allowUserInteraction],
                animations: { window.rootViewController = rootController },
            )
        }
        window.rootViewController = bootController
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneWillResignActive(_: UIScene) {
        isSceneActive = false
        updatePlaybackActivityHold()
        context?.playbackController.setUIPublishingSuspended(true)
        context?.playbackController.persistPlaybackState()
    }

    func sceneDidBecomeActive(_: UIScene) {
        isSceneActive = true
        updatePlaybackActivityHold()
        context?.playbackController.setUIPublishingSuspended(false)
    }

    func sceneDidEnterBackground(_: UIScene) {
        context?.playbackController.persistPlaybackState()
    }

    func sceneDidDisconnect(_: UIScene) {
        isSceneActive = false
        UIApplication.shared.isIdleTimerDisabled = false
        cancellables.removeAll()
        context?.playbackController.setUIPublishingSuspended(true)
        context?.playbackController.persistPlaybackState()
    }
}

private extension TVSceneDelegate {
    func bindPlaybackActivityHold(using context: TVAppContext) {
        cancellables.removeAll()
        isSceneActive = UIApplication.shared.applicationState == .active

        context.playbackController.$snapshot
            .map(\.state)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updatePlaybackActivityHold()
            }
            .store(in: &cancellables)

        updatePlaybackActivityHold()
    }

    func updatePlaybackActivityHold() {
        guard let playbackState = context?.playbackController.latestSnapshot.state else {
            UIApplication.shared.isIdleTimerDisabled = false
            return
        }

        let shouldHoldPlaybackActivity = switch playbackState {
        case .playing, .buffering:
            true
        case .idle, .paused, .error:
            context?.isWithinUserInteractionWindow == true
        }

        UIApplication.shared.isIdleTimerDisabled = isSceneActive && shouldHoldPlaybackActivity
    }
}
