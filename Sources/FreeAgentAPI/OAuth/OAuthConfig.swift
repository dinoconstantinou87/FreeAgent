import Foundation

public struct OAuthConfig: Codable, Sendable {
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
    
    public static func load() throws -> OAuthConfig {
        if let clientId = ProcessInfo.processInfo.environment["FREEAGENT_CLIENT_ID"],
           let clientSecret = ProcessInfo.processInfo.environment["FREEAGENT_CLIENT_SECRET"] {
            let redirectUri = ProcessInfo.processInfo.environment["FREEAGENT_REDIRECT_URI"] ?? "http://localhost:8080/callback"
            return OAuthConfig(clientId: clientId, clientSecret: clientSecret, redirectUri: redirectUri)
        }
        
        let configURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".freeagent")
            .appendingPathComponent("config.json")
        
        if FileManager.default.fileExists(atPath: configURL.path) {
            let data = try Data(contentsOf: configURL)
            return try JSONDecoder().decode(OAuthConfig.self, from: data)
        }
        
        throw OAuthConfigError.notFound
    }
}

public enum OAuthConfigError: LocalizedError {
    case notFound
    
    public var errorDescription: String? {
        switch self {
        case .notFound:
            return "No credentials found. Set FREEAGENT_CLIENT_ID and FREEAGENT_CLIENT_SECRET environment variables or create ~/.freeagent/config.json"
        }
    }
}