import Console
import Foundation
import Yaproq

extension CLI.Chaqmoq {
    /// A command to create a new application.
    public struct New: ParsableCommand {
        /// See `ParsableCommand`.
        public static let configuration = CommandConfiguration(
            abstract: "Creates a new application."
        )

        /// The name of an application.
        @Option(name: [.long, .short], help: "The name of an application.")
        public var name: String

        /// Initializes a new instance.
        public init() {}

        /// Initializes a new instance with the name of an application.
        ///
        /// - Parameter name: The name of an application.
        public init(name: String) {
            self.name = name
        }

        /// See `ParsableCommand`.
        public func run() throws {
            let fileManager = FileManager.default
            let applicationURL = URL(string: fileManager.currentDirectoryPath)!.appendingPathComponent(name)

            if fileManager.fileExists(atPath: applicationURL.path) {
                // TODO: exit with error
            } else {
                // Clone the application template repository
                CLI.shell("git", "clone", "https://github.com/chaqmoq/template.git", name)

                // Set the package and directory name
                let fileURL = applicationURL.appendingPathComponent("Package.swift")
                let templating = Yaproq()
                let result = try templating.renderTemplate(at: fileURL.path, in: ["name": name])
                try fileManager.removeItem(atPath: fileURL.path)
                fileManager.createFile(atPath: fileURL.path, contents: result.data(using: .utf8))

                // Remove the repository specific files
                try fileManager.removeItem(atPath: applicationURL.appendingPathComponent(".git").path)
                try fileManager.removeItem(atPath: applicationURL.appendingPathComponent(".github").path)
                try fileManager.removeItem(atPath: applicationURL.appendingPathComponent("CODE_OF_CONDUCT.md").path)
                try fileManager.removeItem(atPath: applicationURL.appendingPathComponent("CONTRIBUTING.md").path)
                try fileManager.removeItem(atPath: applicationURL.appendingPathComponent("LICENSE").path)
                try fileManager.removeItem(atPath: applicationURL.appendingPathComponent("README.md").path)

                // Install and build the application
                if fileManager.changeCurrentDirectoryPath(applicationURL.path) {
                    CLI.shell("swift", "build")
                } else {
                    // TODO: exit with error
                }
            }
        }
    }
}
