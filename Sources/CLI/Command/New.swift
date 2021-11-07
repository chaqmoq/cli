import Console
import Foundation

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
            let applicationDirectory = "\(fileManager.currentDirectoryPath)/\(name)"

            if fileManager.fileExists(atPath: applicationDirectory) {
                // TODO: exit with error
            } else {
                try fileManager.createDirectory(atPath: applicationDirectory, withIntermediateDirectories: false)
            }

            if fileManager.changeCurrentDirectoryPath(applicationDirectory) {
                CLI.shell("swift", "package", "init", "--type", "executable", "--name", name)
            } else {
                // TODO: exit with error
            }

            CLI.shell("swift", "build")
        }
    }
}
