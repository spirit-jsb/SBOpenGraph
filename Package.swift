// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SBOpenGraph",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(name: "SBOpenGraph", targets: ["SBOpenGraph"]),
    ],
    targets: [
        .target(name: "SBOpenGraph", path: "Sources"),
    ],
    swiftLanguageVersions: [
        .v5,
    ]
)
