import Foundation
import TaggedTime

struct Progress {
    let line: String?
    let duration: Seconds<TimeInterval>
}

final class ProgressTracker: Sendable {
    private let startTimestamp: Seconds<TimeInterval>

    private init(startTimestamp: Seconds<TimeInterval>) {
        self.startTimestamp = startTimestamp
    }

    static func start() -> ProgressTracker {
        ProgressTracker(startTimestamp: Seconds(Date().timeIntervalSince1970))
    }

    func moveForward(_ line: String?) -> Progress {
        let duration = Seconds(Date().timeIntervalSince1970) - startTimestamp
        return Progress(line: line, duration: duration)
    }
}
