import Foundation
import FreeAgentAPI

public struct Config: Codable, Sendable {
    public var auth: Auth

    public init(auth: Auth) {
        self.auth = auth
    }

    public static func load() throws -> Config {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Config.self, from: data)
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

        public init(key: String, secret: String, callbackUrl: URL) {
            self.key = key
            self.secret = secret
            self.callbackUrl = callbackUrl
        }
    }
}
