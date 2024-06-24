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
}
