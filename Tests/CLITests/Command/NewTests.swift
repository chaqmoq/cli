@testable import CLI
import XCTest

final class NewTests: XCTestCase {
    func testConfiguration() {
        // Arrange
        let configuration = CLI.Chaqmoq.New.configuration

        // Assert
        XCTAssertEqual(configuration.abstract, "Creates a new application.")
        XCTAssertNil(configuration.defaultSubcommand)
        XCTAssertTrue(configuration.subcommands.isEmpty)
    }

    func testCommand() {
        // Arrange
        var command = CLI.Chaqmoq.New()

        // Assert
        XCTAssertNotNil(command)

        // Arrange
        let name = "chaqmoq"

        // Act
        command = CLI.Chaqmoq.New(name: name)

        // Assert
        XCTAssertEqual(command.name, name)
        XCTAssertNoThrow(try command.run())
    }
}
