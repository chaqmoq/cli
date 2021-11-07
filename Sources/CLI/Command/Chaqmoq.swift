import Console

extension CLI {
    /// The root command for all `Chaqmoq` application related commands.
    public struct Chaqmoq: ParsableCommand {
        /// See `ParsableCommand`.
        public static let configuration = CommandConfiguration(
            abstract: "Chaqmoq CLI helps developers manage applications.",
            subcommands: [
                New.self,
                Run.self,
                Xcode.self
            ]
        )

        /// Initializes a new instance.
        public init() {}
    }
}
