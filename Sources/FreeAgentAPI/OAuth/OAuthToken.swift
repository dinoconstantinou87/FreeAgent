import Foundation

public struct OAuthToken: Codable, Sendable {
    public let accessToken: String
    public let tokenType: String
    public let expiresIn: Int
    public let refreshToken: String
    public let scope: String?
    public let environment: Environment
    
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
        case environment
    }
    
    public init(accessToken: String, tokenType: String, expiresIn: Int, refreshToken: String, scope: String? = nil, environment: Environment, receivedAt: Date = Date()) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.refreshToken = refreshToken
        self.scope = scope
        self.environment = environment
        self.receivedAt = receivedAt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.tokenType = try container.decode(String.self, forKey: .tokenType)
        self.expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        self.refreshToken = try container.decode(String.self, forKey: .refreshToken)
        self.scope = try container.decodeIfPresent(String.self, forKey: .scope)
        self.environment = try container.decodeIfPresent(Environment.self, forKey: .environment) ?? .sandbox
        self.receivedAt = Date() // Set to current time since API doesn't provide it
    }
    
    public func withEnvironment(_ environment: Environment) -> OAuthToken {
        return OAuthToken(
            accessToken: self.accessToken,
            tokenType: self.tokenType,
            expiresIn: self.expiresIn,
            refreshToken: self.refreshToken,
            scope: self.scope,
            environment: environment,
            receivedAt: self.receivedAt
        )
    }
}