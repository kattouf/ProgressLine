import Foundation
import Yams
import TaggedTime

struct ActivityStyleConfig: Codable {
    let name: String
    let refreshRate: UInt64
    let states: [String]
    let checkmark: String?
    let prompt: String?
}

struct ActivityConfiguration {
    struct StyleConfig {
        let indicator: ActivityIndicator
        let checkmark: String
        let prompt: String
        
        static let defaultCheckmark = "✓"
        static let defaultPrompt = ">"
    }
    
    static func loadConfiguration(from path: String) throws -> [ActivityStyleConfig] {
        let url = URL(fileURLWithPath: path)
        let yamlString = try String(contentsOf: url, encoding: .utf8)
        let decoder = YAMLDecoder()
        return try decoder.decode([ActivityStyleConfig].self, from: yamlString)
    }
    
    static func createStyleConfig(from config: ActivityStyleConfig) -> StyleConfig {
        let configuration = ActivityIndicator.Configuration(
            refreshRate: Milliseconds(config.refreshRate),
            states: config.states
        )
        return StyleConfig(
            indicator: ActivityIndicator(configuration: configuration),
            checkmark: config.checkmark ?? StyleConfig.defaultCheckmark,
            prompt: config.prompt ?? StyleConfig.defaultPrompt
        )
    }
}