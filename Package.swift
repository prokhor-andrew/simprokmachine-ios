// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "simprokmachine",
    platforms: [ .iOS(.v11) ],
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
