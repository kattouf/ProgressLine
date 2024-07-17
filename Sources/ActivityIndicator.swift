import Foundation
import TaggedTime

final class ActivityIndicator: Sendable {
    struct Configuration {
        let refreshRate: Milliseconds<UInt64>
        let states: [String]
    }

    let configuration: Configuration

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    func state(forDuration duration: Seconds<TimeInterval>) -> String {
        let iteration = Int(duration.milliseconds.rawValue / TimeInterval(configuration.refreshRate.rawValue)) % configuration.states.count
        return configuration.states[iteration]
    }
}

extension ActivityIndicator {
    static let dots: ActivityIndicator = {
        let configuration = Configuration(
            refreshRate: 125,
            states: [
                "⠋",
                "⠙",
                "⠹",
                "⠸",
                "⠼",
                "⠴",
                "⠦",
                "⠧",
                "⠇",
                "⠏",
            ]
        )
        return ActivityIndicator(configuration: configuration)
    }()

    static let kitt: ActivityIndicator = {
        let configuration = Configuration(
            refreshRate: 125,
            states: [
                "▰▱▱▱▱",
                "▰▰▱▱▱",
                "▰▰▰▱▱",
                "▱▰▰▰▱",
                "▱▱▰▰▰",
                "▱▱▱▰▰",
                "▱▱▱▱▰",
                "▱▱▱▰▰",
                "▱▱▰▰▰",
                "▱▰▰▰▱",
                "▰▰▰▱▱",
                "▰▰▱▱▱",
            ]
        )
        return ActivityIndicator(configuration: configuration)
    }()

    static let snake: ActivityIndicator = {
        let configuration = Configuration(
            refreshRate: 125,
            states: [
                "▰▱▱▱▱",
                "▰▰▱▱▱",
                "▰▰▰▱▱",
                "▱▰▰▰▱",
                "▱▱▰▰▰",
                "▱▱▱▰▰",
                "▱▱▱▱▰",
                "▱▱▱▱▱",
            ]
        )
        return ActivityIndicator(configuration: configuration)
    }()
}

#if DEBUG
extension ActivityIndicator {
    static func disabled() -> ActivityIndicator {
        .init(
            configuration: .init(refreshRate: 1_000_000_000, states: [])
        )
    }
}
#endif
