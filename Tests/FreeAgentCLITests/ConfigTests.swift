import Configuration
import Foundation
import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

// MARK: - ConfigTests

@Suite(.serialized)
final class ConfigTests {

    // MARK: Lifecycle

    deinit {
        try? FileManager.default.removeItem(at: fileURL)
    }

    // MARK: Internal

    @Test("reads the file written by setup")
    func readsSavedFile() async throws {
        let callbackUrl = try #require(URL(string: "http://localhost:8080/callback"))
        try JSONEncoder().encode(Config(auth: .init(key: "file-key", secret: "file-secret", callbackUrl: callbackUrl)))
            .write(to: fileURL)

        let config = try await AuthConfig(config: reader())

        #expect(config.key == "file-key")
        #expect(config.secret == "file-secret")
        #expect(config.callbackUrl == callbackUrl)
        #expect(config.environment == .production)
    }

    @Test("reads the auth keys from FREEAGENT_AUTH_ environment variables")
    func readsEnvironmentVariables() async throws {
        let config = try await AuthConfig(config: reader(environmentVariables: [
            "FREEAGENT_AUTH_KEY": "env-key",
            "FREEAGENT_AUTH_SECRET": "env-secret",
            "FREEAGENT_AUTH_CALLBACK_URL": "http://localhost:9090/callback",
        ]))

        #expect(config.key == "env-key")
        #expect(config.secret == "env-secret")
        #expect(config.callbackUrl == URL(string: "http://localhost:9090/callback"))
    }

    @Test("prefers environment variables over the file")
    func prefersEnvironmentVariables() async throws {
        try JSONEncoder().encode(["auth": ["key": "file-key"]]).write(to: fileURL)

        let reader = try await reader(environmentVariables: ["FREEAGENT_AUTH_KEY": "env-key"])

        #expect(try reader.requiredString(forKey: "key") == "env-key")
    }

    @Test("uses the given environment over environment variables and the file", arguments: Environment.allCases)
    func usesGivenEnvironment(environment: Environment) async throws {
        let other: Environment = environment == .production ? .sandbox : .production
        try JSONEncoder().encode(["auth": ["environment": other]]).write(to: fileURL)

        let reader = try await reader(
            environment: environment,
            environmentVariables: ["FREEAGENT_AUTH_ENVIRONMENT": other.rawValue]
        )

        #expect(try reader.requiredString(forKey: "environment", as: Environment.self) == environment)
    }

    @Test("names the missing key when nothing is configured")
    func namesMissingKey() async throws {
        let reader = try await reader()

        let error = #expect(throws: (any Error).self) {
            try AuthConfig(config: reader)
        }

        #expect(error.map(String.init(describing:)) == "Missing required config value for key: auth.key.")
    }

    // MARK: Private

    private let fileURL = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).json")

    private func reader(
        environment: Environment = .production,
        environmentVariables: [String: String] = [:]
    ) async throws -> ConfigReader {
        for (name, value) in environmentVariables {
            setenv(name, value, 1)
        }
        defer {
            for name in environmentVariables.keys {
                unsetenv(name)
            }
        }

        return try await Config.reader(environment: environment, fileURL: fileURL).scoped(to: "auth")
    }

}
