@testable import CLI
import XCTest

final class CLITests: XCTestCase {

    // MARK: - CLI.shell

    func testShellSucceeds() {
        // A simple echo should exit 0
        let process = CLI.shell("echo", "Hello World")
        XCTAssertEqual(process.terminationStatus, 0)
    }

    func testShellReturnsNonZeroOnFailure() {
        // `false` is a POSIX utility guaranteed to exit with status 1
        let process = CLI.shell("false")
        XCTAssertNotEqual(process.terminationStatus, 0)
    }

    func testShellReturnsProcessWithCorrectExitCode() {
        // `sh -c "exit 42"` lets us verify the exact code is forwarded
        let process = CLI.shell("sh", "-c", "exit 42")
        XCTAssertEqual(process.terminationStatus, 42)
    }

    func testShellWithUnknownCommandDoesNotCrash() {
        // An unknown command should not crash — CLI.shell catches the error internally
        // and prints it, returning the Process object regardless.
        let process = CLI.shell("__nonexistent_binary_xyz__")
        // We only assert no crash; the exit code depends on the OS.
        XCTAssertNotNil(process)
    }

    func testShellIsDiscardable() {
        // Verify the @discardableResult annotation compiles — no "result unused" warning.
        CLI.shell("true")
    }
}

// MARK: - RuntimeError

final class RuntimeErrorTests: XCTestCase {

    func testErrorDescriptionMatchesMessage() {
        let message = "Something went wrong."
        let error = RuntimeError(message)
        XCTAssertEqual(error.errorDescription, message)
    }

    func testLocalizedDescriptionMatchesMessage() {
        let message = "Cloning failed."
        let error = RuntimeError(message)
        XCTAssertEqual(error.localizedDescription, message)
    }

    func testEmptyMessageIsAllowed() {
        let error = RuntimeError("")
        XCTAssertEqual(error.errorDescription, "")
    }

    func testRuntimeErrorConformsToError() {
        let error: Error = RuntimeError("test")
        XCTAssertNotNil(error)
    }

    func testRuntimeErrorConformsToLocalizedError() {
        let error: LocalizedError = RuntimeError("test")
        XCTAssertNotNil(error.errorDescription)
    }
}
