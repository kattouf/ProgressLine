import ArgumentParser
import TaggedTime

enum ActivityIndicatorStyle: ExpressibleByArgument {
    case dots
    case spinner
    case custom(String)
    
    init?(argument: String) {
        switch argument {
        case "dots": self = .dots
        case "spinner": self = .spinner
        default: self = .custom(argument)
        }
    }
    
    static var allCases: [String] {
        ["dots", "spinner"]
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
                print("\(ANSI.yellow)[!] progressline: Failed to load custom style '\(styleName)' from config: \(error)\(ANSI.reset)")
            }
        }
        
        // Fallback to built-in styles
        switch style {
        case .dots: return .dots
        case .spinner: return .spinner
        case .custom(_): return .spinner // Default to spinner if custom style fails to load
        }
    }
}