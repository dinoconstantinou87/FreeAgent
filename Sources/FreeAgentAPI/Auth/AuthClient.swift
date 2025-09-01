import Foundation
@preconcurrency import OAuthSwift

public struct AuthClient: Sendable {
    private let client: OAuth2Swift
    private let environment: Environment
    private let storage = AuthStorage()

    public init(key: String, secret: String, environment: Environment) {
        self.environment = environment
        client = OAuth2Swift(
            consumerKey: key,
            consumerSecret: secret,
            authorizeUrl: environment.url("v2/approve_app"),
            accessTokenUrl: environment.url("v2/token_endpoint"),
            responseType: "code"
        )
    }

    public func authorize(callbackUrl: URL) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            client.authorize(withCallbackURL: callbackUrl, scope: "", state: "") { result in
                do {
                    try handle(result)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func refresh() async throws {
        guard let credential = try storage.get() else {
            throw AuthClientError.noCredentialFound
        }

        return try await withCheckedThrowingContinuation { continuation in
            client.renewAccessToken(withRefreshToken: credential.refreshToken) { result in
                do {
                    try handle(result)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func handle(_ result: Result<OAuthSwift.TokenSuccess, OAuthSwiftError>) throws {
        switch result {
        case .success(let (result, _, _)):
            let credential = AuthCredential(
                token: result.oauthToken,
                refreshToken: result.oauthRefreshToken,
                expiresAt: result.oauthTokenExpiresAt,
                environment: environment
            )

            try storage.set(credential)
        case .failure(let error):
            throw error
        }
    }

    public func handle(url: URL) {
        OAuthSwift.handle(url: url)
    }
}

public enum AuthClientError: Error {
    case noCredentialFound
}
