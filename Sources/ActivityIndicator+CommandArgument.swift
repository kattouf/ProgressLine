import ArgumentParser

enum ActivityIndicatorStyle: ExpressibleByArgument {
    case dots
    case kitt
    case snake
    case spinner
    case wave
    case bounce
    case custom(String)
    
    init?(argument: String) {
        switch argument {
        case "dots": self = .dots
        case "kitt": self = .kitt
        case "snake": self = .snake
        case "spinner": self = .spinner
        case "wave": self = .wave
        case "bounce": self = .bounce
        default: self = .custom(argument)
        }
    }
    
    static var allCases: [String] {
        ["dots", "kitt", "snake", "spinner", "wave", "bounce"]
    }
}

extension ActivityIndicator {
    static func make(style: ActivityIndicatorStyle, configPath: String?) -> ActivityIndicator {
        if case let .custom(styleName) = style, let configPath = configPath {
            do {
                let configs = try ActivityConfiguration.loadConfiguration(from: configPath)
                if let matchingConfig = configs.first(where: { $0.name == styleName }) {
                    return ActivityConfiguration.createActivityIndicator(from: matchingConfig)
                }
            } catch {
                print("Warning: Failed to load custom style '\(styleName)' from config: \(error)")
            }
        }
        
        // Fallback to built-in styles
        switch style {
        case .dots: return .dots
        case .kitt: return .kitt
        case .snake: return .snake
        case .spinner: return .spinner
        case .wave: return .wave
        case .bounce: return .bounce
        case .custom(_): return .spinner // Default to spinner if custom style fails to load
        }
    }
}