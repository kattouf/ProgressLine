// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "SakeApp",
    platforms: [.macOS(.v10_15)], // Required by SwiftSyntax for the macro feature in Sake
    products: [
        .executable(name: "SakeApp", targets: ["SakeApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kattouf/Sake", from: "0.1.0"),
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "SakeApp",
            dependencies: [
                "Sake",
                "SwiftShell",
            ],
            path: "."
        ),
    ]
)
