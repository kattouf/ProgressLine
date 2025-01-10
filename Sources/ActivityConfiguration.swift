import Foundation
import Yams

struct ActivityStyleConfig: Codable {
    let name: String
    let refreshRate: UInt64
    let states: [String]
}

struct ActivityConfiguration {
    static func loadConfiguration(from path: String) throws -> [ActivityStyleConfig] {
        let url = URL(fileURLWithPath: path)
        let yamlString = try String(contentsOf: url, encoding: .utf8)
        let decoder = YAMLDecoder()
        return try decoder.decode([ActivityStyleConfig].self, from: yamlString)
    }
    
    static func createActivityIndicator(from config: ActivityStyleConfig) -> ActivityIndicator {
        let configuration = ActivityIndicator.Configuration(
            refreshRate: Milliseconds(config.refreshRate),
            states: config.states
        )
        return ActivityIndicator(configuration: configuration)
    }
}