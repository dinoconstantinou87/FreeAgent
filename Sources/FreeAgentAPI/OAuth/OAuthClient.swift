import Foundation

public struct OAuthClient: Sendable {
    private let flow: OAuthFlow
    private let storage: OAuthTokenStorage
    private let config: OAuthConfig
    
    public init(config: OAuthConfig, environment: Environment = .sandbox) {
        self.config = config
        self.flow = OAuthFlow(environment: environment)
        self.storage = OAuthTokenStorage()
    }
    
    public func authorizationURL(state: String? = nil) -> URL {
        flow.authorizationURL(config: config, state: state)
    }
    
    public func authenticate(code: String) async throws -> OAuthToken {
        let token = try await flow.exchangeCodeForToken(code: code, config: config)
        try storage.save(token)
        return token
    }
    
    public func currentToken() throws -> OAuthToken? {
        guard let token = try storage.load() else {
            return nil
        }
        
        return token
    }
    
    public func isAuthenticated() throws -> Bool {
        try storage.hasValidToken()
    }
    
    public func authenticationStatus() throws -> AuthStatus {
        guard let token = try storage.load() else {
            return .notAuthenticated
        }
        
        if token.isExpired {
            return .expired(refreshToken: token.refreshToken)
        }
        
        return .authenticated(expiresIn: token.timeUntilExpiration)
    }
    
    public func logout() throws {
        try storage.clear()
    }
}

public enum AuthStatus: CustomStringConvertible, Sendable {
    case notAuthenticated
    case authenticated(expiresIn: TimeInterval)
    case expired(refreshToken: String)
    
    public var description: String {
        switch self {
        case .notAuthenticated:
            return "Not authenticated"
        case .authenticated(let expiresIn):
            let minutes = Int(expiresIn / 60)
            if minutes > 0 {
                return "Authenticated (expires in \(minutes) minutes)"
            } else {
                return "Authenticated (expires soon)"
            }
        case .expired:
            return "Token expired (refresh token available)"
        }
    }
}