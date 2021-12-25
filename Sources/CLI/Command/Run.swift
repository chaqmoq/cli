import Console
import DotEnv
import Foundation

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

            let queue = DispatchQueue(label: "dev.chaqmoq.cli.shutdown")
            let terminationSignal = makeSignal(SIGTERM, on: queue)
            terminationSignal.resume()
            let interruptionSignal = makeSignal(SIGINT, on: queue)
            interruptionSignal.resume()

            CLI.shell("swift", "run")
        }

        private func makeSignal(_ code: Int32, on queue: DispatchQueue? = nil) -> DispatchSourceSignal {
            let signalSource = DispatchSource.makeSignalSource(signal: code, queue: queue)
            signalSource.setEventHandler {
                let port = 8080
                let outputPipe = Pipe()
                let process = Process()
                process.launchPath = "/usr/bin/env"
                process.arguments = ["lsof", "-t", "-i:\(port)"]
                process.standardOutput = outputPipe
                process.waitUntilExit()
                process.launch()

                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let pid = String(decoding: outputData, as: UTF8.self).trimmingCharacters(in: .newlines)

                CLI.shell("kill", "-9", "\(pid)")
            }
            signal(code, SIG_IGN)

            return signalSource
        }
    }
}
