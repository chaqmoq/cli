import Foundation

public struct CLI {
    @discardableResult
    public static func shell(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()

        return task.terminationStatus
    }
}
