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

            // A missing .env file is a warning, not a fatal error —
            // projects without one should still be runnable.
            do {
                try dotEnv.load(at: ".env.\(environment)")
            } catch {
                print("Warning: Could not load environment file .env.\(environment): \(error)")
            }

            // POSIX signal disposition must be set to SIG_IGN *before* creating dispatch sources.
            // A signal arriving between source creation and this call would invoke the default
            // handler (process termination).
            signal(SIGTERM, SIG_IGN)
            signal(SIGINT, SIG_IGN)

            // Start swift run as a non-blocking Process so signal handlers can terminate it.
            // Using CLI.shell would block via waitUntilExit(), making it impossible for the
            // signal handler to reach the child process.
            let swiftProcess = Process()
            swiftProcess.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            swiftProcess.arguments = ["swift", "run"]

            do {
                try swiftProcess.run()
            } catch {
                print("Failed to start swift run: \(error)")
                return
            }

            let queue = DispatchQueue(label: "dev.chaqmoq.cli.shutdown")
            let terminationSignal = makeSignal(SIGTERM, process: swiftProcess, on: queue)
            let interruptionSignal = makeSignal(SIGINT, process: swiftProcess, on: queue)
            terminationSignal.resume()
            interruptionSignal.resume()

            // Block until swift run exits, keeping signal source objects alive for the duration.
            withExtendedLifetime((terminationSignal, interruptionSignal)) {
                swiftProcess.waitUntilExit()
            }
        }

        private func makeSignal(
            _ code: Int32,
            process: Process,
            on queue: DispatchQueue? = nil
        ) -> DispatchSourceSignal {
            let signalSource = DispatchSource.makeSignalSource(signal: code, queue: queue)
            signalSource.setEventHandler {
                let port = 8080
                let outputPipe = Pipe()
                let lsofProcess = Process()
                lsofProcess.executableURL = URL(fileURLWithPath: "/usr/bin/env")
                lsofProcess.arguments = ["lsof", "-t", "-i:\(port)"]
                lsofProcess.standardOutput = outputPipe

                do {
                    try lsofProcess.run()
                    lsofProcess.waitUntilExit()
                } catch {
                    print("Failed to run lsof: \(error)")
                }

                let output = String(
                    decoding: outputPipe.fileHandleForReading.readDataToEndOfFile(),
                    as: UTF8.self
                )
                // lsof -t can return multiple PIDs (one per line); kill each one individually.
                // Passing the whole newline-separated string as a single argument to kill silently
                // fails when more than one process holds the port.
                let pids = output.split(whereSeparator: \.isWhitespace).map(String.init)
                for pid in pids {
                    CLI.shell("kill", "-9", pid)
                }

                // Terminate the swift run process. waitUntilExit() on the main thread will
                // unblock once the process exits, so run() returns and the CLI exits naturally —
                // no explicit exit() call needed (and calling it would kill the test runner).
                process.terminate()
            }

            return signalSource
        }
    }
}
