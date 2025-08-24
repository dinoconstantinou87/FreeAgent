import Foundation

public struct OAuthFlow: Sendable {
    public enum Environment: String, Sendable {
        case production = "https://api.freeagent.com"
        case sandbox = "https://api.sandbox.freeagent.com"
        
        public var authorizationURL: URL {
            URL(string: "\(rawValue)/v2/approve_app")!
        }
        
        public var tokenURL: URL {
            URL(string: "\(rawValue)/v2/token_endpoint")!
        }
    }
    
    private let environment: Environment
    private let urlSession: URLSession
    
    public init(environment: Environment = .sandbox, urlSession: URLSession = .shared) {
        self.environment = environment
        self.urlSession = urlSession
    }
    
    public func authorizationURL(config: OAuthConfig, state: String? = nil) -> URL {
        var components = URLComponents(url: environment.authorizationURL, resolvingAgainstBaseURL: false)!
        
        var queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: config.clientId),
            URLQueryItem(name: "redirect_uri", value: config.redirectUri)
        ]
        
        if let state = state {
            queryItems.append(URLQueryItem(name: "state", value: state))
        }
        
        components.queryItems = queryItems
        return components.url!
    }
    
    public func exchangeCodeForToken(code: String, config: OAuthConfig) async throws -> OAuthToken {
        var request = URLRequest(url: environment.tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "grant_type": "authorization_code",
            "code": code,
            "client_id": config.clientId,
            "client_secret": config.clientSecret,
            "redirect_uri": config.redirectUri
        ]
        
        let bodyString = parameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
        
        request.httpBody = bodyString.data(using: .utf8)
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OAuthError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OAuthError.tokenExchangeFailed(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        guard !data.isEmpty else {
            throw OAuthError.tokenExchangeFailed(statusCode: httpResponse.statusCode, message: "Empty response data")
        }
        
        let decoder = JSONDecoder()
        do {
            let token = try decoder.decode(OAuthToken.self, from: data)
            return token
        } catch {
            let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
            throw OAuthError.tokenExchangeFailed(statusCode: httpResponse.statusCode, message: "JSON decode error: \(error.localizedDescription). Response: \(responseString)")
        }
    }
    
    public func refreshToken(_ refreshToken: String, config: OAuthConfig) async throws -> OAuthToken {
        var request = URLRequest(url: environment.tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": config.clientId,
            "client_secret": config.clientSecret
        ]
        
        let bodyString = parameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
        
        request.httpBody = bodyString.data(using: .utf8)
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OAuthError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw OAuthError.tokenRefreshFailed(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(OAuthToken.self, from: data)
    }
}

public enum OAuthError: LocalizedError {
    case invalidResponse
    case tokenExchangeFailed(statusCode: Int, message: String)
    case tokenRefreshFailed(statusCode: Int, message: String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .tokenExchangeFailed(let statusCode, let message):
            return "Failed to exchange authorization code for token (HTTP \(statusCode)): \(message)"
        case .tokenRefreshFailed(let statusCode, let message):
            return "Failed to refresh token (HTTP \(statusCode)): \(message)"
        }
    }
}