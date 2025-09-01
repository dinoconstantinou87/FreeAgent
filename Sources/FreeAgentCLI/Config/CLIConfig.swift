import Foundation
import FreeAgentAPI

public struct CLIConfig: Codable, Sendable {
    public let clientId: String
    public let clientSecret: String
    public let redirectUri: String
    
    private enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case redirectUri = "redirect_uri"
    }
    
    public init(clientId: String, clientSecret: String, redirectUri: String = "http://localhost:8080/callback") {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUri = redirectUri
    }
    
    public static func load() throws -> CLIConfig {
        if let clientId = ProcessInfo.processInfo.environment["FREEAGENT_CLIENT_ID"],
           let clientSecret = ProcessInfo.processInfo.environment["FREEAGENT_CLIENT_SECRET"] {
            let redirectUri = ProcessInfo.processInfo.environment["FREEAGENT_REDIRECT_URI"] ?? "http://localhost:8080/callback"
            return CLIConfig(clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri)
        }
        
        let configURL = configFileURL()
        
        if FileManager.default.fileExists(atPath: configURL.path) {
            let data = try Data(contentsOf: configURL)
            return try JSONDecoder().decode(CLIConfig.self, from: data)
        }
        
        throw CLIConfigError.notFound
    }
    
    public func save() throws {
        let configURL = Self.configFileURL()
        
        let configDir = configURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: configDir.path) {
            try FileManager.default.createDirectory(at: configDir, withIntermediateDirectories: true)
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        try data.write(to: configURL)
    }
    
    private static func configFileURL() -> URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".freeagent")
            .appendingPathComponent("config.json")
    }
}

public enum CLIConfigError: LocalizedError {
    case notFound
    
    public var errorDescription: String? {
        switch self {
        case .notFound:
            return "No credentials found. Set FREEAGENT_CLIENT_ID and FREEAGENT_CLIENT_SECRET environment variables or create ~/.freeagent/config.json"
        }
    }
}
