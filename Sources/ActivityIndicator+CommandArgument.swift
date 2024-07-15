import ArgumentParser

enum ActivityIndicatorStyle: String, CaseIterable, ExpressibleByArgument {
    case dots
    case kitt
    case snake
}

extension ActivityIndicator {
    static func make(style: ActivityIndicatorStyle) -> ActivityIndicator {
        switch style {
        case .dots:
            .dots
        case .kitt:
            .kitt
        case .snake:
            .snake
        }
    }

    #if DEBUG
    static func test() -> ActivityIndicator {
        .init(
          configuration: .init(refreshRate: 1_000_000_000, states: ["<activity>"])
        )
    }
    #endif
}
