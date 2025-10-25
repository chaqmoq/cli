import Foundation

public struct CLI {
    @discardableResult
    public static func shell(_ args: String...) -> Process {
        let process = Process()
        process.executableURL = .init(fileURLWithPath: "/usr/bin/env")
        process.arguments = args

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            print("Failed to run process: \(error)")
        }

        return process
    }
}
