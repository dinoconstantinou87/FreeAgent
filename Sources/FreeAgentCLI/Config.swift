import Configuration
import Foundation
import FreeAgentAPI

// MARK: - Config

public struct Config: Codable, Sendable {

    // MARK: Lifecycle

    public init(auth: Auth) {
        self.auth = auth
    }

    // MARK: Public

    public var auth: Auth

    public func save() throws {
        let url = Config.url
        let files = FileManager.default
        let directory = url.deletingLastPathComponent()

        if !files.fileExists(atPath: directory.path) {
            try files.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        try data.write(to: url)
    }

    // MARK: Internal

    static let url = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".freeagent")
        .appendingPathComponent("config.json")

    static func reader(
        environment: Environment,
        fileURL: URL = url
    ) async throws -> ConfigReader {
        try await ConfigReader(providers: [
            InMemoryProvider(name: "arguments", values: [
                "auth.environment": ConfigValue(.string(environment.rawValue), isSecret: false)
            ]),
            EnvironmentVariablesProvider().prefixKeys(with: "freeagent"),
            FileProvider<JSONSnapshot>(filePath: .init(fileURL.path(percentEncoded: false)), allowMissing: true),
        ])
    }

}

// MARK: Config.Auth

extension Config {
    public struct Auth: Codable, Sendable {

        // MARK: Lifecycle

        public init(key: String, secret: String, callbackUrl: URL) {
            self.key = key
            self.secret = secret
            self.callbackUrl = callbackUrl
        }

        // MARK: Public

        public var key: String
        public var secret: String
        public var callbackUrl: URL

    }
}
