@testable import CLI
import XCTest

final class RunTests: XCTestCase {
    func testConfiguration() {
        // Arrange
        let configuration = CLI.Chaqmoq.Run.configuration

        // Assert
        XCTAssertEqual(configuration.abstract, "Runs an application.")
        XCTAssertNil(configuration.defaultSubcommand)
        XCTAssertTrue(configuration.subcommands.isEmpty)
    }

    func testCommand() {
        // Arrange
        var command = CLI.Chaqmoq.Run()

        // Assert
        XCTAssertNotNil(command)

        // Act
        command = CLI.Chaqmoq.Run(environment: nil)

        // Assert
        XCTAssertNil(command.environment)
        XCTAssertNoThrow(try command.run())

        // Arrange
        let environment = "production"

        // Act
        command = CLI.Chaqmoq.Run(environment: environment)

        // Assert
        XCTAssertEqual(command.environment, environment)
        XCTAssertNoThrow(try command.run())
    }
}
