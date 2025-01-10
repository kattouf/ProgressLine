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
    static func make(style: ActivityIndicatorStyle, configPath: String?) -> (indicator: ActivityIndicator, checkmark: String, prompt: String) {
        let defaultConfig = (indicator: ActivityIndicator.spinner, checkmark: ActivityConfiguration.StyleConfig.defaultCheckmark, prompt: ActivityConfiguration.StyleConfig.defaultPrompt)
        // Debug logging for configuration loading
        print("Style: \(style), Config Path: \(configPath ?? "nil")")
        if case let .custom(styleName) = style, let configPath = configPath {
            do {
                let configs = try ActivityConfiguration.loadConfiguration(from: configPath)
                if let matchingConfig = configs.first(where: { $0.name == styleName }) {
                    let styleConfig = ActivityConfiguration.createStyleConfig(from: matchingConfig)
                    return (indicator: styleConfig.indicator, checkmark: styleConfig.checkmark, prompt: styleConfig.prompt)
                }
            } catch {
                print("\(ANSI.yellow)[!] progressline: Failed to load custom style '\(styleName)' from config: \(error)\(ANSI.reset)")
            }
        }
        
        // Fallback to built-in styles
        switch style {
        case .dots: return defaultConfig
        case .spinner: return defaultConfig
        case .custom(_): return defaultConfig
        }
    }
}