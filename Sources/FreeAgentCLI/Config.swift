import Foundation
import FreeAgentAPI
import Configuration

public struct Config: Codable, Sendable {
    public var auth: Auth

    public init(auth: Auth) {
        self.auth = auth
    }

    public static func load() async throws -> Config {
        let reader = ConfigReader(providers: [
            try await JSONProvider(filePath: .init(url.path()))
        ])

        return Config(auth: try Auth(reader: reader.scoped(to: "auth")))
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
    
    private static let url = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".freeagent")
        .appendingPathComponent("config.json")
}

extension Config {
    public struct Auth: Codable, Sendable {
        public var key: String
        public var secret: String
        public var callbackUrl: URL

        public init(reader: ConfigReader) throws {
            self.key = try reader.requiredString(forKey: "key")
            self.secret = try reader.requiredString(forKey: "secret", isSecret: true)

            if let callbackUrl = URL(string: try reader.requiredString(forKey: "callbackUrl")) {
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
    }
}

enum ConfigError: Error {
    case invalidUrl
}
