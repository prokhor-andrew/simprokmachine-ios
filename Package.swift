// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "simprokmachine",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "simprokmachine",
            targets: ["simprokmachine"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "simprokmachine",
            dependencies: []
        )
    ]
)
