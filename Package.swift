// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "chaqmoq-cli",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "CLI", targets: ["CLI"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/chaqmoq/console.git", from: "master"),
        .package(url: "https://github.com/chaqmoq/dotenv.git", from: "master"),
        .package(url: "https://github.com/yaproq/yaproq.git", from: "master")
    ],
    targets: [
        .target(name: "CLI", dependencies: [
            .product(name: "Console", package: "chaqmoq-console"),
            .product(name: "DotEnv", package: "chaqmoq-dotenv"),
            .product(name: "Yaproq", package: "yaproq")
        ]),
        .target(name: "Run", dependencies: [
            .target(name: "CLI")
        ]),
        .testTarget(name: "CLITests", dependencies: [
            .target(name: "CLI")
        ])
    ],
    swiftLanguageVersions: [.v5]
)
