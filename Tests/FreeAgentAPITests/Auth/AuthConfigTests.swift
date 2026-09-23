import Configuration
import Foundation
import Testing

@testable import FreeAgentAPI

// MARK: - AuthConfigTests

struct AuthConfigTests {

    // MARK: Internal

    @Test("reads the key, secret, callback URL and environment from the reader")
    func readsValues() throws {
        let config = try AuthConfig(config: ConfigReader(provider: InMemoryProvider(values: values)))

        #expect(config.key == "the-key")
        #expect(config.secret == "the-secret")
        #expect(config.callbackUrl == URL(string: "http://localhost:8080/callback"))
        #expect(config.environment == .sandbox)
    }

    @Test("throws when a required key is missing", arguments: ["key", "secret", "callbackUrl", "environment"])
    func throwsWhenMissing(key: String) throws {
        let reader = ConfigReader(provider: InMemoryProvider(values: values.filter { $0.key != AbsoluteConfigKey([key]) }))

        let error = #expect(throws: (any Error).self) {
            try AuthConfig(config: reader)
        }

        #expect(error.map(String.init(describing:)) == "Missing required config value for key: \(key).")
    }

    @Test("throws when the environment is not recognised")
    func throwsForUnknownEnvironment() {
        var values = values
        values["environment"] = "staging"
        let reader = ConfigReader(provider: InMemoryProvider(values: values))

        #expect(throws: (any Error).self) {
            try AuthConfig(config: reader)
        }
    }

    @Test("marks only the secret as secret")
    func marksSecret() async throws {
        try await confirmation(expectedCount: values.count) { reported in
            let reporter = ClosureAccessReporter { event in
                reported()
                #expect((try? event.result.get())?.isSecret == (event.metadata.key == AbsoluteConfigKey(["secret"])))
            }

            _ = try AuthConfig(config: ConfigReader(provider: InMemoryProvider(values: values), accessReporter: reporter))
        }
    }

    // MARK: Private

    private let values: [AbsoluteConfigKey: ConfigValue] = [
        "key": "the-key",
        "secret": "the-secret",
        "callbackUrl": "http://localhost:8080/callback",
        "environment": "sandbox",
    ]

}

// MARK: - ClosureAccessReporter

private struct ClosureAccessReporter: AccessReporter {
    let onReport: @Sendable (AccessEvent) -> Void

    func report(_ event: AccessEvent) {
        onReport(event)
    }
}
