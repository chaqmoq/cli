import Foundation

public struct CLI {
    @discardableResult
    public static func shell(_ args: String...) -> Process {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = args
        process.launch()
        process.waitUntilExit()

        return process
    }
}
