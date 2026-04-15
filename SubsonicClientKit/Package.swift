//
//  Package.swift
//  SubsonicClientKit
//
//  Created by @Lakr233 on 2026/04/11.
//

// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SubsonicClientKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SubsonicClientKit",
            targets: ["SubsonicClientKit"],
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SubsonicClientKit",
            resources: [
                .process("Resources"),
            ],
        ),
        .testTarget(
            name: "SubsonicClientKitTests",
            dependencies: ["SubsonicClientKit"],
            resources: [
                .process("Fixtures"),
            ],
        ),
    ],
)
