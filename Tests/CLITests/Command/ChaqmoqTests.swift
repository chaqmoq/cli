@testable import CLI
import XCTest

final class ChaqmoqTests: XCTestCase {
    func testConfiguration() {
        // Arrange
        let configuration = CLI.Chaqmoq.configuration

        // Assert
        XCTAssertEqual(configuration.abstract, "Chaqmoq CLI helps developers manage applications.")
        XCTAssertNil(configuration.defaultSubcommand)
        XCTAssertEqual(configuration.subcommands.count, 3)
        XCTAssertEqual(configuration.subcommands[0]._commandName, "new")
        XCTAssertEqual(configuration.subcommands[1]._commandName, "run")
        XCTAssertEqual(configuration.subcommands[2]._commandName, "xcode")
    }

    func testCommand() {
        // Arrange
        let command = CLI.Chaqmoq()

        // Assert
        XCTAssertNotNil(command)
    }
}
