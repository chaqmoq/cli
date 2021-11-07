# Chaqmoq CLI
[![Swift](https://img.shields.io/badge/swift-5.3-brightgreen.svg)](https://swift.org/download/#releases) [![MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](https://github.com/chaqmoq/cli/blob/master/LICENSE/) [![Actions Status](https://github.com/chaqmoq/cli/workflows/development/badge.svg)](https://github.com/chaqmoq/cli/actions) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/6f4d115b5e644a208e8ecf23999f3405)](https://www.codacy.com/gh/chaqmoq/cli/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=chaqmoq/cli&amp;utm_campaign=Badge_Grade) [![codecov](https://codecov.io/gh/chaqmoq/cli/branch/master/graph/badge.svg?token=A2LEC0YCYL)](https://codecov.io/gh/chaqmoq/cli) [![Documentation](https://github.com/chaqmoq/cli/blob/gh-pages/badge.svg)](https://chaqmoq.dev/cli/) [![Contributing](https://img.shields.io/badge/contributing-guide-brightgreen.svg)](https://github.com/chaqmoq/cli/blob/master/CONTRIBUTING.md) [![Twitter](https://img.shields.io/badge/twitter-chaqmoqdev-brightgreen.svg)](https://twitter.com/chaqmoqdev)

## Installation
### Swift
Download and install [Swift](https://swift.org/download)

### Swift Package
```shell
mkdir MyApp
cd MyApp
swift package init --type executable // Creates an executable app named "MyApp"
```

#### Package.swift
```swift
// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "MyApp",
    dependencies: [
        .package(name: "chaqmoq-cli", url: "https://github.com/chaqmoq/cli.git", .branch("master"))
    ],
    targets: [
        .target(name: "MyApp", dependencies: [
            .product(name: "CLI", package: "chaqmoq-cli"),
        ]),
        .testTarget(name: "MyAppTests", dependencies: [
            .target(name: "MyApp")
        ])
    ]
)
```

### Build
```shell
swift build -c release
```

## Tests
```shell
swift test --enable-test-discovery --sanitize=thread
```
