import Foundation
@preconcurrency import OAuthSwift

public struct AuthClient: Sendable {
    private let oauth: OAuth2Swift
    private let environment: Environment
    private let storage = AuthStorage()

    public init(key: String, secret: String, environment: Environment) {
        self.environment = environment
        oauth = OAuth2Swift(
            consumerKey: key,
            consumerSecret: secret,
            authorizeUrl: environment.url("v2/approve_app"),
            accessTokenUrl: environment.url("v2/token_endpoint"),
            responseType: "code"
        )
    }

    public func authorize(callbackUrl: URL) async throws {
        let oauth = oauth
        let environment = environment

        return try await withCheckedThrowingContinuation { continuation in
            oauth.authorize(
                withCallbackURL: callbackUrl,
                scope: "",
                state: ""
            ) { result in
                switch result {
                case .success(let (result, _, _)):
                    let credential = AuthCredential(
                        token: result.oauthToken,
                        refreshToken: result.oauthRefreshToken,
                        expiresAt: result.oauthTokenExpiresAt,
                        environment: environment
                    )

                    do {
                        try storage.set(credential)
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func handle(url: URL) {
        OAuthSwift.handle(url: url)
    }
}
