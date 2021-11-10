// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "chaqmoq-cli",
    platforms: [
        .macOS(.v10_11)
    ],
    products: [
        .library(name: "CLI", targets: ["CLI"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(name: "chaqmoq-console", url: "https://github.com/chaqmoq/console.git", .branch("master")),
        .package(name: "chaqmoq-dotenv", url: "https://github.com/chaqmoq/dotenv.git", .branch("master")),
        .package(name: "yaproq", url: "https://github.com/yaproq/yaproq.git", .branch("master"))
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
