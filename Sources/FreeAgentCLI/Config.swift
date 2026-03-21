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

    public static func load() async throws -> Config {
        let reader = try await ConfigReader(providers: [
            JSONProvider(filePath: .init(url.path()))
        ])

        return try Config(auth: Auth(reader: reader.scoped(to: "auth")))
    }

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

    // MARK: Private

    private static let url = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".freeagent")
        .appendingPathComponent("config.json")
}

// MARK: Config.Auth

extension Config {
    public struct Auth: Codable, Sendable {

        // MARK: Lifecycle

        public init(reader: ConfigReader) throws {
            key = try reader.requiredString(forKey: "key")
            secret = try reader.requiredString(forKey: "secret", isSecret: true)

            if let callbackUrl = try URL(string: reader.requiredString(forKey: "callbackUrl")) {
                self.callbackUrl = callbackUrl
            } else {
                throw ConfigError.invalidUrl
            }
        }

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

// MARK: - ConfigError

enum ConfigError: Error {
    case invalidUrl
}
