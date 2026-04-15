//
//  main.swift
//  MuseAmpTV
//
//  Created by @Lakr233 on 2026/04/11.
//

import UIKit

MainActor.assumeIsolated {
    AppLog.info("main", "Entering UIApplicationMain for MuseAmpTV")
    _ = UIApplicationMain(
        CommandLine.argc,
        CommandLine.unsafeArgv,
        nil,
        NSStringFromClass(TVAppDelegate.self),
    )

    AppLog.error("main", "MuseAmpTV UIApplicationMain returned unexpectedly")
    fatalError("UIApplicationMain returned unexpectedly.")
}
