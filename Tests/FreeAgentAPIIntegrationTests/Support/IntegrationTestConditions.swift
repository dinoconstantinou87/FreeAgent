import Foundation
import Testing

enum IntegrationTest {
    static func isModelEnabled(_ model: String) -> Bool {
        guard let token = ProcessInfo.processInfo.environment["FREEAGENT_ACCESS_TOKEN"], !token.isEmpty else {
            return false
        }

        guard let changed = ProcessInfo.processInfo.environment["CHANGED_MODELS"], !changed.isEmpty else {
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
