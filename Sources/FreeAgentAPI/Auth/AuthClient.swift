import Foundation
@preconcurrency import OAuthSwift

// MARK: - AuthClient

public struct AuthClient: Sendable {

    // MARK: Lifecycle

    public init(config: AuthConfig) {
        self.config = config
        client = OAuth2Swift(
            consumerKey: config.key,
            consumerSecret: config.secret,
            authorizeUrl: config.environment.url("v2/approve_app"),
            accessTokenUrl: config.environment.url("v2/token_endpoint"),
            responseType: "code"
        )
    }

    // MARK: Public

    public func authorize(callbackUrl: URL) async throws {
        try await withCheckedThrowingContinuation { continuation in
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

    public func handle(url: URL) {
        OAuthSwift.handle(url: url)
    }

    // MARK: Internal

    func refresh() async throws -> AuthCredential {
        guard let credential = try storage.get() else {
            throw AuthClientError.noCredentialFound
        }

        return try await withCheckedThrowingContinuation { continuation in
            client.renewAccessToken(withRefreshToken: credential.refreshToken) { result in
                do {
                    try continuation.resume(returning: handle(result))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: Private

    private let config: AuthConfig
    private let client: OAuth2Swift
    private let storage = AuthStorage()

    @discardableResult
    private func handle(_ result: Result<OAuthSwift.TokenSuccess, OAuthSwiftError>) throws -> AuthCredential {
        switch result {
        case .success((let result, _, _)):
            let credential = AuthCredential(
                token: result.oauthToken,
                refreshToken: result.oauthRefreshToken,
                expiresAt: result.oauthTokenExpiresAt,
                environment: config.environment
            )

            try storage.set(credential)

            return credential

        case .failure(let error):
            throw error
        }
    }

}

// MARK: - AuthClientError

public enum AuthClientError: Error {
    case noCredentialFound
}
