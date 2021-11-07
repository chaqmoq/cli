import Console
import DotEnv

extension CLI.Chaqmoq {
    /// A command to run an application.
    public struct Run: ParsableCommand {
        /// See `ParsableCommand`.
        public static let configuration = CommandConfiguration(
            abstract: "Runs an application."
        )

        /// An application environment.
        @Option(name: [.customLong("env"), .short], help: "The environment of an application.")
        public var environment: String?

        /// Initializes a new instance.
        public init() {}

        /// Initializes a new instance with the environment of an application.
        ///
        /// - Parameter environment: The environment of an application.
        public init(environment: String?) {
            self.environment = environment
        }

        /// See `ParsableCommand`.
        public func run() throws {
            let environment = self.environment ?? "development"
            let dotEnv = DotEnv()
            dotEnv.set(environment, forKey: "CHAQMOQ_ENV")
            CLI.shell("swift", "run")
        }
    }
}
