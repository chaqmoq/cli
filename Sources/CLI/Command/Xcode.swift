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

        #if os(macOS)
        /// Injectable opener — defaults to `NSWorkspace.shared.open(_:)`.
        /// Override in tests to suppress the real Xcode.app launch.
        public var _opener: ((URL) -> Void)? = nil

        // Closures can't conform to Decodable, so exclude _opener from the
        // synthesised init(from:). Only the command-line arguments need decoding.
        private enum CodingKeys: String, CodingKey {
            case name
        }
        #endif

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
                let open = _opener ?? { NSWorkspace.shared.open($0) }
                open(fileURL)
            } else {
                print("Can't find a manifest file \"\(fileName)\" to open at \"\(fileURL.path)\".")
            }
            #else
            // Construct the full path so that --name is respected on non-macOS platforms.
            let fileURL = URL(fileURLWithPath: applicationDirectory).appendingPathComponent(fileName)
            if fileManager.fileExists(atPath: fileURL.path) {
                CLI.shell("open", fileURL.path)
            } else {
                print("Can't find a manifest file \"\(fileName)\" to open at \"\(fileURL.path)\".")
            }
            #endif
        }
    }
}
