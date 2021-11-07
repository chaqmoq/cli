@testable import CLI
import XCTest

final class XcodeTests: XCTestCase {
    func testConfiguration() {
        // Arrange
        let configuration = CLI.Chaqmoq.Xcode.configuration

        // Assert
        XCTAssertEqual(configuration.abstract, "Opens an application on Xcode.")
        XCTAssertEqual(configuration.defaultSubcommand?._commandName, "open")
        XCTAssertEqual(configuration.subcommands.count, 1)
        XCTAssertEqual(configuration.subcommands[0]._commandName, "open")
    }

    func testCommand() {
        // Arrange
        let command = CLI.Chaqmoq.Xcode()

        // Assert
        XCTAssertNotNil(command)
    }
}

final class OpenTests: XCTestCase {
    func testConfiguration() {
        // Arrange
        let configuration = CLI.Chaqmoq.Xcode.Open.configuration

        // Assert
        XCTAssertEqual(configuration.abstract, "Opens an application on Xcode.")
        XCTAssertNil(configuration.defaultSubcommand)
        XCTAssertTrue(configuration.subcommands.isEmpty)
    }

    func testCommand() {
        // Arrange
        var command = CLI.Chaqmoq.Xcode.Open()

        // Assert
        XCTAssertNotNil(command)

        // Act
        command = CLI.Chaqmoq.Xcode.Open(name: nil)

        // Assert
        XCTAssertNil(command.name)
        XCTAssertNoThrow(try command.run())

        // Arrange
        let name = "chaqmoq"

        // Act
        command = CLI.Chaqmoq.Xcode.Open(name: name)

        // Assert
        XCTAssertEqual(command.name, name)
        XCTAssertNoThrow(try command.run())
    }
}

