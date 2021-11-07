#if os(macOS)
import AppKit
#endif
import Console
import Foundation

extension CLI.Chaqmoq {
    /// A parent command for all Xcode related subcommands. By default, it runs the `Open` subcommand.
    public struct Xcode: ParsableCommand {
        /// See `ParsableCommand`.
        public static let configuration = CommandConfiguration(
            abstract: "Opens an application on Xcode.",
            subcommands: [
                Open.self
            ],
            defaultSubcommand: Open.self
        )

        /// Initializes a new instance.
        public init() {}
    }
}

extension CLI.Chaqmoq.Xcode {
    /// Opens an application on Xcode.
    public struct Open: ParsableCommand {
        /// See `ParsableCommand`.
        public static let configuration = CommandConfiguration(
            abstract: "Opens an application on Xcode."
        )

        @Option(name: [.long, .short], help: "The name of an application.")
        /// The name of an application.
        public var name: String?

        /// Initializes a new instance with the name of an application.
        ///
        /// - Parameter name: The name of an application.
        public init(name: String?) {
            self.name = name
        }

        /// Initializes a new instance.
        public init() {}

        /// See `ParsableCommand`.
        public func run() throws {
            let fileManager = FileManager.default
            var applicationDirectory = "\(fileManager.currentDirectoryPath)"
            if let name = name { applicationDirectory += "/\(name)" }
            let fileName = "Package.swift"

            #if os(macOS)
            var fileURL = URL(fileURLWithPath: applicationDirectory)
            fileURL.appendPathComponent(fileName)

            if fileManager.fileExists(atPath: fileURL.path) {
                NSWorkspace.shared.open(fileURL)
            } else {
                // TODO: exit with error
            }
            #else
            CLI.shell("open", fileName)
            #endif
        }
    }
}
