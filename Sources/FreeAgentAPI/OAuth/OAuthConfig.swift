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
}