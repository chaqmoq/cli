@testable import CLI
import XCTest

final class NewTests: XCTestCase {

    // MARK: - Configuration

    func testConfiguration() {
        let configuration = CLI.Chaqmoq.New.configuration
        XCTAssertEqual(configuration.abstract, "Creates a new application.")
        XCTAssertNil(configuration.defaultSubcommand)
        XCTAssertTrue(configuration.subcommands.isEmpty)
    }

    // MARK: - Initialization

    func testDefaultInit() {
        let command = CLI.Chaqmoq.New()
        XCTAssertNotNil(command)
    }

    func testInitWithName() {
        let name = "my-app"
        let command = CLI.Chaqmoq.New(name: name)
        XCTAssertEqual(command.name, name)
    }

    func testNameWithSpaces() {
        let name = "my cool app"
        let command = CLI.Chaqmoq.New(name: name)
        XCTAssertEqual(command.name, name)
    }

    func testNameWithSpecialCharacters() {
        let name = "app-v2.0_beta"
        let command = CLI.Chaqmoq.New(name: name)
        XCTAssertEqual(command.name, name)
    }

    // MARK: - run() — "already exists" branch

    func testRunPrintsMessageWhenApplicationAlreadyExists() throws {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
            .appendingPathComponent("CLITests-\(UUID().uuidString)")
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempDir) }

        let appName = "existing-app"
        try fileManager.createDirectory(
            at: tempDir.appendingPathComponent(appName),
            withIntermediateDirectories: true
        )

        let originalDir = fileManager.currentDirectoryPath
        guard fileManager.changeCurrentDirectoryPath(tempDir.path) else {
            throw XCTSkip("Could not change working directory.")
        }
        defer { fileManager.changeCurrentDirectoryPath(originalDir) }

        // "already exists" branch just prints — must not throw.
        XCTAssertNoThrow(try CLI.Chaqmoq.New(name: appName).run())
    }

    // MARK: - run() — clone failure (PATH injection)

    func testRunThrowsRuntimeErrorWhenGitCloneFails() throws {
        // A fake git binary that exits 1 immediately triggers the
        // `guard cloneProcess.terminationStatus == 0` throw path without any network access.
        let fileManager = FileManager.default
        let fakeBinDir = try makeTempDir(fileManager, prefix: "CLITests-bin")
        defer { try? fileManager.removeItem(at: fakeBinDir) }

        try makeScript("#!/bin/sh\nexit 1\n", at: fakeBinDir.appendingPathComponent("git"))

        let workDir = try makeTempDir(fileManager, prefix: "CLITests-work")
        defer { try? fileManager.removeItem(at: workDir) }

        try withFakePath(fakeBinDir) {
            let originalDir = fileManager.currentDirectoryPath
            guard fileManager.changeCurrentDirectoryPath(workDir.path) else {
                throw XCTSkip("Could not change working directory.")
            }
            defer { fileManager.changeCurrentDirectoryPath(originalDir) }

            XCTAssertThrowsError(try CLI.Chaqmoq.New(name: "test-app").run()) { error in
                XCTAssertTrue(error is RuntimeError)
                XCTAssertTrue(
                    (error as? RuntimeError)?.errorDescription?.contains("exit code 1") == true
                )
            }
        }
    }

    // MARK: - run() — full happy path (PATH injection)

    func testRunSucceedsWithFakeGitAndFakeSwift() throws {
        // Fake git creates the directory structure that New.run() expects after a real clone.
        // Fake swift exits immediately so `swift build` doesn't compile anything.
        // Together they cover template rendering, atomic write, file cleanup, and build call.
        let fileManager = FileManager.default
        let fakeBinDir = try makeTempDir(fileManager, prefix: "CLITests-bin")
        defer { try? fileManager.removeItem(at: fakeBinDir) }

        // `git clone <url> <name>` — $3 is the destination directory name.
        // Creates the minimal template structure that New.run() expects.
        try makeScript(
            """
            #!/bin/sh
            DEST="$3"
            mkdir -p "$DEST" "$DEST/.git" "$DEST/.github"
            echo '// swift-tools-version:5.9' > "$DEST/Package.swift"
            echo 'import PackageDescription' >> "$DEST/Package.swift"
            echo 'let package = Package(name: "{{ name }}")' >> "$DEST/Package.swift"
            touch "$DEST/README.md" "$DEST/LICENSE" "$DEST/CODE_OF_CONDUCT.md" "$DEST/CONTRIBUTING.md"
            exit 0
            """,
            at: fakeBinDir.appendingPathComponent("git")
        )

        // `swift build` — exits 0 instantly so the test doesn't compile anything real.
        try makeScript("#!/bin/sh\nexit 0\n", at: fakeBinDir.appendingPathComponent("swift"))

        let workDir = try makeTempDir(fileManager, prefix: "CLITests-work")
        defer { try? fileManager.removeItem(at: workDir) }

        try withFakePath(fakeBinDir) {
            let originalDir = fileManager.currentDirectoryPath
            guard fileManager.changeCurrentDirectoryPath(workDir.path) else {
                throw XCTSkip("Could not change working directory.")
            }
            defer { fileManager.changeCurrentDirectoryPath(originalDir) }

            let appName = "test-app"
            XCTAssertNoThrow(try CLI.Chaqmoq.New(name: appName).run())

            // Verify the app directory exists and cleanup removed template-only files.
            let appDir = workDir.appendingPathComponent(appName)
            XCTAssertTrue(fileManager.fileExists(atPath: appDir.path))
            XCTAssertTrue(
                fileManager.fileExists(atPath: appDir.appendingPathComponent("Package.swift").path)
            )
            XCTAssertFalse(
                fileManager.fileExists(atPath: appDir.appendingPathComponent("README.md").path)
            )
            XCTAssertFalse(
                fileManager.fileExists(atPath: appDir.appendingPathComponent("LICENSE").path)
            )
            XCTAssertFalse(
                fileManager.fileExists(atPath: appDir.appendingPathComponent(".git").path)
            )
            XCTAssertFalse(
                fileManager.fileExists(atPath: appDir.appendingPathComponent(".github").path)
            )
            XCTAssertFalse(
                fileManager.fileExists(
                    atPath: appDir.appendingPathComponent("CODE_OF_CONDUCT.md").path
                )
            )
            XCTAssertFalse(
                fileManager.fileExists(
                    atPath: appDir.appendingPathComponent("CONTRIBUTING.md").path
                )
            )
        }
    }

    // MARK: - Integration (skipped in unit test runs)

    func testRunCreatesApplication() throws {
        throw XCTSkip("Integration test: requires network access and file system setup.")
    }

    // MARK: - Helpers

    @discardableResult
    private func makeTempDir(_ fileManager: FileManager, prefix: String) throws -> URL {
        let dir = fileManager.temporaryDirectory.appendingPathComponent("\(prefix)-\(UUID().uuidString)")
        try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func makeScript(_ content: String, at url: URL) throws {
        try content.write(to: url, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: url.path)
    }

    /// Prepends `dir` to PATH for the duration of `body`, then restores the original value.
    private func withFakePath(_ dir: URL, body: () throws -> Void) rethrows {
        let original = ProcessInfo.processInfo.environment["PATH"] ?? "/usr/bin:/bin"
        setenv("PATH", "\(dir.path):\(original)", 1)
        defer { setenv("PATH", original, 1) }
        try body()
    }
}
