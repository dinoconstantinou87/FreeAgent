import Configuration
import Foundation
import Testing

@testable import FreeAgentAPI

enum IntegrationTest {
    static func isModelEnabled(_ model: String) -> Bool {
        guard SandboxClient.token != nil else {
            return false
        }

        let reader = ConfigReader(providers: [EnvironmentVariablesProvider()])

        guard let changed = reader.string(forKey: "changedModels"), !changed.isEmpty else {
            // No CHANGED_MODELS set means run all (e.g. local testing)
            return true
        }

        if changed == "all" {
            return true
        }

        let models = changed.split(separator: ",").map(String.init)
        return models.contains(model)
    }
}
