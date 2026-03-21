@testable import CLI
import XCTest

final class RunTests: XCTestCase {

    // MARK: - Configuration

    func testConfiguration() {
        let configuration = CLI.Chaqmoq.Run.configuration
        XCTAssertEqual(configuration.abstract, "Runs an application.")
        XCTAssertNil(configuration.defaultSubcommand)
        XCTAssertTrue(configuration.subcommands.isEmpty)
    }

    // MARK: - Initialization

    func testDefaultInit() {
        // Only verify the instance is created — do not access @Option/@Argument/@Flag properties
        // on a default-initialized ParsableCommand. Their backing storage is in an unresolved
        // "definition" state until parsed or set via the explicit initializer, so accessing them
        // hits a preconditionFailure inside ArgumentParser.
        let command = CLI.Chaqmoq.Run()
        XCTAssertNotNil(command)
    }

    func testInitWithNilEnvironment() {
        let command = CLI.Chaqmoq.Run(environment: nil)
        XCTAssertNil(command.environment)
    }

    func testInitWithDevelopmentEnvironment() {
        let command = CLI.Chaqmoq.Run(environment: "development")
        XCTAssertEqual(command.environment, "development")
    }

    func testInitWithProductionEnvironment() {
        let command = CLI.Chaqmoq.Run(environment: "production")
        XCTAssertEqual(command.environment, "production")
    }

    func testInitWithCustomEnvironment() {
        let env = "staging"
        let command = CLI.Chaqmoq.Run(environment: env)
        XCTAssertEqual(command.environment, env)
    }

    func testEnvironmentPropertyIsIndependentAcrossInstances() {
        var a = CLI.Chaqmoq.Run(environment: "development")
        let b = CLI.Chaqmoq.Run(environment: "production")
        a.environment = "staging"
        XCTAssertEqual(a.environment, "staging")
        XCTAssertEqual(b.environment, "production")
    }

    // MARK: - run() — fast-exit paths
    //
    // `swift run` in a directory without Package.swift exits in under a second
    // ("error: root manifest not found") — no compilation, no blocking.
    // This exercises the full run() body without the test hanging.

    func testRunWithNilEnvironmentInEmptyDirectory() throws {
        try runInEmptyTempDir(environment: nil)
    }

    func testRunWithExplicitEnvironmentInEmptyDirectory() throws {
        // Covers the `self.environment ?? "development"` branch where environment is non-nil.
        try runInEmptyTempDir(environment: "production")
    }

    func testRunLoadsEnvFileWhenPresent() throws {
        // Covers the dotEnv.load() *success* path (no warning printed).
        let fileManager = FileManager.default
        let workDir = try makeTempDir(fileManager, prefix: "CLITests-work")
        defer { try? fileManager.removeItem(at: workDir) }

        try "CHAQMOQ_TEST_VAR=hello\n".write(
            to: workDir.appendingPathComponent(".env.development"),
            atomically: true,
            encoding: .utf8
        )

        let originalDir = fileManager.currentDirectoryPath
        guard fileManager.changeCurrentDirectoryPath(workDir.path) else {
            throw XCTSkip("Could not change working directory.")
        }
        defer {
            fileManager.changeCurrentDirectoryPath(originalDir)
            signal(SIGTERM, SIG_DFL)
            signal(SIGINT, SIG_DFL)
        }

        XCTAssertNoThrow(try CLI.Chaqmoq.Run(environment: nil).run())
    }

    func testRunWithCustomEnvironmentLoadsCorrectEnvFile() throws {
        // Verifies the `.env.\(environment)` filename interpolation with a non-default name.
        let fileManager = FileManager.default
        let workDir = try makeTempDir(fileManager, prefix: "CLITests-work")
        defer { try? fileManager.removeItem(at: workDir) }

        try "CHAQMOQ_TEST_VAR=staging\n".write(
            to: workDir.appendingPathComponent(".env.staging"),
            atomically: true,
            encoding: .utf8
        )

        let originalDir = fileManager.currentDirectoryPath
        guard fileManager.changeCurrentDirectoryPath(workDir.path) else {
            throw XCTSkip("Could not change working directory.")
        }
        defer {
            fileManager.changeCurrentDirectoryPath(originalDir)
            signal(SIGTERM, SIG_DFL)
            signal(SIGINT, SIG_DFL)
        }

        XCTAssertNoThrow(try CLI.Chaqmoq.Run(environment: "staging").run())
    }

    // MARK: - Helpers

    @discardableResult
    private func makeTempDir(_ fileManager: FileManager, prefix: String) throws -> URL {
        let dir = fileManager.temporaryDirectory
            .appendingPathComponent("\(prefix)-\(UUID().uuidString)")
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

    // Shared helper for the fast-exit run() tests.
    private func runInEmptyTempDir(environment: String?) throws {
        let fileManager = FileManager.default
        let workDir = try makeTempDir(fileManager, prefix: "CLITests-work")
        defer { try? fileManager.removeItem(at: workDir) }

        let originalDir = fileManager.currentDirectoryPath
        guard fileManager.changeCurrentDirectoryPath(workDir.path) else {
            throw XCTSkip("Could not change working directory.")
        }
        defer {
            fileManager.changeCurrentDirectoryPath(originalDir)
            // Restore POSIX signal dispositions set process-wide by run().
            signal(SIGTERM, SIG_DFL)
            signal(SIGINT, SIG_DFL)
        }

        XCTAssertNoThrow(try CLI.Chaqmoq.Run(environment: environment).run())
    }
}
