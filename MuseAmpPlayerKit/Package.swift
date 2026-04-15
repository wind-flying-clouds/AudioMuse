//
//  Package.swift
//  MuseAmpPlayerKit
//
//  Created by @Lakr233 on 2026/04/11.
//

// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MuseAmpPlayerKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .tvOS(.v16), .macOS(.v12)],
    products: [
        .library(
            name: "MuseAmpPlayerKit",
            targets: ["MuseAmpPlayerKit"],
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
    ],
    targets: [
        .target(
            name: "MuseAmpPlayerKit",
            dependencies: ["Kingfisher"],
            resources: [
                .process("Resources"),
            ],
        ),
        .testTarget(
            name: "MuseAmpPlayerKitTests",
            dependencies: ["MuseAmpPlayerKit"],
        ),
    ],
    swiftLanguageModes: [.v6],
)
