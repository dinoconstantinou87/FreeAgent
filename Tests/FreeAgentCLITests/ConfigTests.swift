import Configuration
import Foundation
import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

// MARK: - ConfigTests

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

    @Test("reads every auth key from FREEAGENT_AUTH_ environment variables")
    func readsEnvironmentVariables() async throws {
        let config = try await AuthConfig(config: reader(environmentVariables: [
            "FREEAGENT_AUTH_KEY": "env-key",
            "FREEAGENT_AUTH_SECRET": "env-secret",
            "FREEAGENT_AUTH_CALLBACK_URL": "http://localhost:9090/callback",
            "FREEAGENT_AUTH_ENVIRONMENT": "sandbox",
        ]))

        #expect(config.key == "env-key")
        #expect(config.secret == "env-secret")
        #expect(config.callbackUrl == URL(string: "http://localhost:9090/callback"))
        #expect(config.environment == .sandbox)
    }

    @Test("reads --environment from the command line", arguments: [
        ["auth", "login", "--environment", "sandbox"],
        ["auth", "login", "--environment=sandbox"],
    ])
    func readsCommandLine(arguments: [String]) async throws {
        let reader = try await reader(arguments: arguments)

        #expect(try reader.requiredString(forKey: "environment", as: Environment.self) == .sandbox)
    }

    @Test(
        "resolves the environment from overrides, then the command line, then environment variables, then the file",
        arguments: [
            (override: nil, argument: nil, variable: nil, file: nil, expected: Environment.production),
            (override: nil, argument: nil, variable: nil, file: .sandbox, expected: .sandbox),
            (override: nil, argument: nil, variable: .production, file: .sandbox, expected: .production),
            (override: nil, argument: .sandbox, variable: .production, file: .sandbox, expected: .sandbox),
            (override: .production, argument: .sandbox, variable: .production, file: .sandbox, expected: .production),
        ] as [(Environment?, Environment?, Environment?, Environment?, Environment)]
    )
    func resolvesEnvironment(
        override: Environment?,
        argument: Environment?,
        variable: Environment?,
        file: Environment?,
        expected: Environment
    ) async throws {
        if let file {
            try JSONEncoder().encode(["auth": ["environment": file]]).write(to: fileURL)
        }

        let reader = try await reader(
            overrides: override.map { override in
                [InMemoryProvider(values: ["auth.environment": ConfigValue(.string(override.rawValue), isSecret: false)])]
            } ?? [],
            arguments: argument.map { ["--environment", $0.rawValue] } ?? [],
            environmentVariables: variable.map { ["FREEAGENT_AUTH_ENVIRONMENT": $0.rawValue] } ?? [:]
        )

        #expect(try reader.requiredString(forKey: "environment", as: Environment.self) == expected)
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
        overrides: [any ConfigProvider] = [],
        arguments: [String] = [],
        environmentVariables: [String: String] = [:]
    ) async throws -> ConfigReader {
        try await Config.reader(
            overrides: overrides,
            arguments: ["freeagent"] + arguments,
            environmentVariables: environmentVariables,
            fileURL: fileURL
        )
        .scoped(to: "auth")
    }

}
