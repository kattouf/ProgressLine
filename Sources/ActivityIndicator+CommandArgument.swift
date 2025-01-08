import ArgumentParser

enum ActivityIndicatorStyle: String, CaseIterable, ExpressibleByArgument {
    case dots
    case kitt
    case snake
    case spinner
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
        case .spinner:
            .spinner
        }
    }
}
