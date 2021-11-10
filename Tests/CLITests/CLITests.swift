@testable import CLI
import XCTest

final class CLITests: XCTestCase {
    func testShell() {
        XCTAssertEqual(CLI.shell("echo", "Hello World").terminationStatus, 0)
    }
}
