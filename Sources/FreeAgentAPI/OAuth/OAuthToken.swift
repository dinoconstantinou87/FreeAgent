import Foundation

public struct OAuthToken: Codable, Sendable {
    public let accessToken: String
    public let tokenType: String
    public let expiresIn: Int
    public let refreshToken: String
    public let scope: String?
    
    public let receivedAt: Date
    
    public var isExpired: Bool {
        let expirationDate = receivedAt.addingTimeInterval(TimeInterval(expiresIn))
        return Date() >= expirationDate
    }
    
    public var timeUntilExpiration: TimeInterval {
        let expirationDate = receivedAt.addingTimeInterval(TimeInterval(expiresIn))
        return expirationDate.timeIntervalSinceNow
    }
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
    
    public init(accessToken: String, tokenType: String, expiresIn: Int, refreshToken: String, scope: String? = nil, receivedAt: Date = Date()) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.refreshToken = refreshToken
        self.scope = scope
        self.receivedAt = receivedAt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.tokenType = try container.decode(String.self, forKey: .tokenType)
        self.expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        self.refreshToken = try container.decode(String.self, forKey: .refreshToken)
        self.scope = try container.decodeIfPresent(String.self, forKey: .scope)
        self.receivedAt = Date() // Set to current time since API doesn't provide it
    }
}