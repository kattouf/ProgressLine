// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProgressLine",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(name: "progressline", targets: ["progressline"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
        .package(url: "https://github.com/pointfreeco/swift-tagged.git", from: "0.10.0"),
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras.git", from: "1.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "progressline",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "TaggedTime", package: "swift-tagged"),
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
            ], swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
    ]
)
