// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "chaqmoq-cli",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(name: "CLI", targets: ["CLI"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/chaqmoq/console.git", branch: "master"),
        .package(url: "https://github.com/chaqmoq/dotenv.git", branch: "master"),
        .package(url: "https://github.com/yaproq/yaproq.git", branch: "master")
    ],
    targets: [
        .target(name: "CLI", dependencies: [
            .product(name: "Console", package: "console"),
            .product(name: "DotEnv", package: "dotenv"),
            .product(name: "Yaproq", package: "yaproq")
        ]),
        .executableTarget(name: "Run", dependencies: [
            .target(name: "CLI")
        ]),
        .testTarget(name: "CLITests", dependencies: [
            .target(name: "CLI")
        ])
    ],
    swiftLanguageVersions: [.v5]
)
