import Foundation
import OAuthenticator

public struct AuthCredential: Codable, Sendable {

    // MARK: Lifecycle

    public init(token: String, refreshToken: String?, expiresAt: Date?, environment: Environment) {
        self.token = token
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
        self.environment = environment
    }

    init(login: Login, environment: Environment) {
        self.init(
            token: login.accessToken.value,
            refreshToken: login.refreshToken?.value,
            expiresAt: login.accessToken.expiry,
            environment: environment
        )
    }

    // MARK: Public

    public let token: String
    public let refreshToken: String?
    public let expiresAt: Date?
    public let environment: Environment

    // MARK: Internal

    var login: Login {
        Login(
            accessToken: Token(value: token, expiry: expiresAt),
            refreshToken: refreshToken.map { Token(value: $0) }
        )
    }

}
