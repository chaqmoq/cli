import Foundation

/// A simple error type for throwing descriptive messages from command implementations.
public struct RuntimeError: LocalizedError {
    public let errorDescription: String?

    public init(_ message: String) {
        errorDescription = message
    }
}
