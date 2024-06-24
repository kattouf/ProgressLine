#if os(Linux)
// Linux implementation of FileHandle not Sendable
@preconcurrency import Foundation
#else
import Foundation
#endif

extension FileHandle {
    var asyncStream: AsyncStream<Data> {
        AsyncStream { continuation in
            Task {
                while let data = try waitAndReadAvailableData() {
                    continuation.yield(data)
                }
                continuation.finish()
            }
        }
    }

    private func waitAndReadAvailableData() throws -> Data? {
        let data = availableData
        guard !data.isEmpty else {
            return nil
        }
        return data
    }
}
