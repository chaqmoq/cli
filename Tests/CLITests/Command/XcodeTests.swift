@testable import CLI
import XCTest

final class XcodeTests: XCTestCase {

    // MARK: - Configuration

    func testConfiguration() {
        let configuration = CLI.Chaqmoq.Xcode.configuration
        XCTAssertEqual(configuration.abstract, "Opens an application on Xcode.")
        XCTAssertEqual(configuration.defaultSubcommand?._commandName, "open")
        XCTAssertEqual(configuration.subcommands.count, 1)
        XCTAssertEqual(configuration.subcommands[0]._commandName, "open")
    }

    // MARK: - Initialization

    func testDefaultInit() {
        let command = CLI.Chaqmoq.Xcode()
        XCTAssertNotNil(command)
    }
}

// MARK: -

final class OpenTests: XCTestCase {

    // MARK: - Configuration

    func testConfiguration() {
        let configuration = CLI.Chaqmoq.Xcode.Open.configuration
        XCTAssertEqual(configuration.abstract, "Opens an application on Xcode.")
        XCTAssertNil(configuration.defaultSubcommand)
        XCTAssertTrue(configuration.subcommands.isEmpty)
    }

    // MARK: - Initialization

    func testDefaultInit() {
        // Only verify the instance is created — see testInitWithNilName for the nil check.
        let command = CLI.Chaqmoq.Xcode.Open()
        XCTAssertNotNil(command)
    }

    func testInitWithNilName() {
        let command = CLI.Chaqmoq.Xcode.Open(name: nil)
        XCTAssertNil(command.name)
    }

    func testInitWithName() {
        let name = "my-app"
        let command = CLI.Chaqmoq.Xcode.Open(name: name)
        XCTAssertEqual(command.name, name)
    }

    func testNamePropertyIsIndependentAcrossInstances() {
        var a = CLI.Chaqmoq.Xcode.Open(name: "app-a")
        let b = CLI.Chaqmoq.Xcode.Open(name: "app-b")
        a.name = "app-c"
        XCTAssertEqual(a.name, "app-c")
        XCTAssertEqual(b.name, "app-b")
    }

    // MARK: - run() — manifest present (covers NSWorkspace.shared.open)

    func testRunOpensManifestWhenItExists() throws {
        // Creates a placeholder Package.swift so fileExists returns true and the
        // opener branch is exercised. The opener is injected as a no-op so no
        // real Xcode.app launch occurs (which would trigger an async system dialog
        // after the temp file is deleted by the defer block).
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
            .appendingPathComponent("CLITests-\(UUID().uuidString)")
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDir) }

        try "// placeholder".write(
            to: tempDir.appendingPathComponent("Package.swift"),
            atomically: true,
            encoding: .utf8
        )

        let originalDir = fileManager.currentDirectoryPath
        guard fileManager.changeCurrentDirectoryPath(tempDir.path) else {
            throw XCTSkip("Could not change working directory.")
        }
        defer { fileManager.changeCurrentDirectoryPath(originalDir) }

        var openedURL: URL?
        var command = CLI.Chaqmoq.Xcode.Open(name: nil)
        command._opener = { openedURL = $0 }
        XCTAssertNoThrow(try command.run())
        XCTAssertEqual(openedURL?.lastPathComponent, "Package.swift")
    }

    func testRunOpensManifestWithNameWhenItExists() throws {
        // Same as above but exercises the `--name` branch: applicationDirectory += "/\(name)".
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
            .appendingPathComponent("CLITests-\(UUID().uuidString)")
        let appName = "my-app"
        let appDir = tempDir.appendingPathComponent(appName)
        try fileManager.createDirectory(at: appDir, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDir) }

        try "// placeholder".write(
            to: appDir.appendingPathComponent("Package.swift"),
            atomically: true,
            encoding: .utf8
        )

        let originalDir = fileManager.currentDirectoryPath
        guard fileManager.changeCurrentDirectoryPath(tempDir.path) else {
            throw XCTSkip("Could not change working directory.")
        }
        defer { fileManager.changeCurrentDirectoryPath(originalDir) }

        var openedURL: URL?
        var command = CLI.Chaqmoq.Xcode.Open(name: appName)
        command._opener = { openedURL = $0 }
        XCTAssertNoThrow(try command.run())
        XCTAssertEqual(openedURL?.lastPathComponent, "Package.swift")
    }

    // MARK: - run() — manifest absent

    func testRunDoesNotThrowWhenManifestIsMissingWithNoName() throws {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
            .appendingPathComponent("CLITests-\(UUID().uuidString)")
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDir) }

        let originalDir = fileManager.currentDirectoryPath
        guard fileManager.changeCurrentDirectoryPath(tempDir.path) else {
            throw XCTSkip("Could not change working directory.")
        }
        defer { fileManager.changeCurrentDirectoryPath(originalDir) }

        XCTAssertNoThrow(try CLI.Chaqmoq.Xcode.Open(name: nil).run())
    }

    func testRunDoesNotThrowWhenManifestIsMissingWithName() throws {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
            .appendingPathComponent("CLITests-\(UUID().uuidString)")
        let appName = "ghost-app"
        let appDir = tempDir.appendingPathComponent(appName)
        try fileManager.createDirectory(at: appDir, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDir) }

        let originalDir = fileManager.currentDirectoryPath
        guard fileManager.changeCurrentDirectoryPath(tempDir.path) else {
            throw XCTSkip("Could not change working directory.")
        }
        defer { fileManager.changeCurrentDirectoryPath(originalDir) }

        XCTAssertNoThrow(try CLI.Chaqmoq.Xcode.Open(name: appName).run())
    }

    func testRunDoesNotThrowWhenSubdirectoryDoesNotExistAtAll() throws {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
            .appendingPathComponent("CLITests-\(UUID().uuidString)")
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDir) }

        let originalDir = fileManager.currentDirectoryPath
        guard fileManager.changeCurrentDirectoryPath(tempDir.path) else {
            throw XCTSkip("Could not change working directory.")
        }
        defer { fileManager.changeCurrentDirectoryPath(originalDir) }

        XCTAssertNoThrow(try CLI.Chaqmoq.Xcode.Open(name: "does-not-exist").run())
    }
}
