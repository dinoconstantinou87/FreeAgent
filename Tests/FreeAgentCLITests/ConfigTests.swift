import Configuration
import Foundation
import Testing

@testable import FreeAgentCLI

struct ConfigTests {

    @Test("environment variables override the config file")
    func variablesOverrideFile() throws {
        let reader = ConfigReader(providers: [
            EnvironmentVariablesProvider(environmentVariables: [
                "FREEAGENT_AUTH_KEY": "variable-key",
                "FREEAGENT_AUTH_SECRET": "variable-secret",
            ]).prefixKeys(with: "freeagent"),
            InMemoryProvider(values: [
                "auth.key": "file-key",
                "auth.secret": "file-secret",
                "auth.callbackUrl": "https://example.com/file",
            ]),
        ])

        let auth = try Config.Auth(reader: reader.scoped(to: "auth"))

        #expect(auth.key == "variable-key")
        #expect(auth.secret == "variable-secret")
        #expect(auth.callbackUrl == URL(string: "https://example.com/file"))
    }

    @Test("the config file supplies values no variable overrides")
    func fileSuppliesRemainingValues() throws {
        let reader = ConfigReader(providers: [
            EnvironmentVariablesProvider(environmentVariables: [:]).prefixKeys(with: "freeagent"),
            InMemoryProvider(values: [
                "auth.key": "file-key",
                "auth.secret": "file-secret",
                "auth.callbackUrl": "https://example.com/file",
            ]),
        ])

        let auth = try Config.Auth(reader: reader.scoped(to: "auth"))

        #expect(auth.key == "file-key")
        #expect(auth.secret == "file-secret")
    }

    @Test("load reads an existing config file")
    func loadReadsFile() async throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("config.json")

        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data(#"{"auth":{"key":"k","secret":"s","callbackUrl":"https://example.com/cb"}}"#.utf8)
            .write(to: url)

        let config = try await Config.load(from: url)

        #expect(config.auth.key == "k")
        #expect(config.auth.secret == "s")
        #expect(config.auth.callbackUrl == URL(string: "https://example.com/cb"))
    }

    @Test("load tolerates a missing config file and reports the missing key instead")
    func loadToleratesMissingFile() async throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("config.json")

        await #expect(throws: (any Error).self) {
            try await Config.load(from: url)
        }
    }

    @Test("an invalid callback url is rejected")
    func invalidCallbackUrlIsRejected() {
        let reader = ConfigReader(providers: [
            InMemoryProvider(values: [
                "auth.key": "k",
                "auth.secret": "s",
                "auth.callbackUrl": "",
            ])
        ])

        #expect(throws: (any Error).self) {
            try Config.Auth(reader: reader.scoped(to: "auth"))
        }
    }

}
