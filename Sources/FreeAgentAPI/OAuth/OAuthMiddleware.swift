import Foundation
import OpenAPIRuntime
import HTTPTypes

public struct OAuthMiddleware: ClientMiddleware {
    private let oauthClient: OAuthClient
    private let environment: Environment
    private let config: OAuthConfig

    public init(oauthClient: OAuthClient, config: OAuthConfig, environment: Environment = .sandbox) {
        self.oauthClient = oauthClient
        self.config = config
        self.environment = environment
    }
    
    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        
        var authenticatedRequest = request
        
        if let token = try oauthClient.currentToken() {
            if token.isExpired {
            }
            
            authenticatedRequest.headerFields[.authorization] = "Bearer \(token.accessToken)"
        } else {
            throw OAuthMiddlewareError.noTokenAvailable
        }
        
        let (response, responseBody) = try await next(authenticatedRequest, body, baseURL)
        
        if response.status == .unauthorized, let token = try? oauthClient.currentToken(), !token.refreshToken.isEmpty {
            do {
                let flow = OAuthFlow(environment: environment)
                let newToken = try await flow.refreshToken(token.refreshToken, config: config)
                
                let storage = OAuthTokenStorage()
                try storage.save(newToken)
                
                var retryRequest = request
                retryRequest.headerFields[.authorization] = "Bearer \(newToken.accessToken)"
                return try await next(retryRequest, body, baseURL)
                
            } catch {
                return (response, responseBody)
            }
        }
        
        return (response, responseBody)
    }
}

public enum OAuthMiddlewareError: LocalizedError {
    case noTokenAvailable
    case tokenRefreshFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .noTokenAvailable:
            return "No authentication token available. Please login first."
        case .tokenRefreshFailed(let error):
            return "Failed to refresh authentication token: \(error.localizedDescription)"
        }
    }
}

extension ClientMiddleware where Self == OAuthMiddleware {
    public static func oauth(client: OAuthClient, config: OAuthConfig, environment: Environment = .sandbox) -> OAuthMiddleware {
        OAuthMiddleware(oauthClient: client, config: config, environment: environment)
    }
}
