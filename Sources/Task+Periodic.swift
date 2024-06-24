import Foundation
import TaggedTime

extension Task where Success == Never, Failure == any Error {
    @discardableResult
    static func periodic(interval: Milliseconds<UInt64>, operation: @Sendable @escaping () async throws -> Void) -> Task {
        Task {
            while true {
                try Task<Never, Never>.checkCancellation()
                try await operation()
                try await Task<Never, Never>.sleep(nanoseconds: 1_000_000 * interval.rawValue)
            }
        }
    }
}
