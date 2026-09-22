import Foundation
import OAuthenticator

public struct AuthConfig: Sendable {

    // MARK: Lifecycle

    public init(key: String, secret: String, callbackUrl: URL, environment: Environment) {
        self.key = key
        self.secret = secret
        self.callbackUrl = callbackUrl
        self.environment = environment
    }

    // MARK: Public

    public let key: String
    public let secret: String
    public let callbackUrl: URL
    public let environment: Environment

    // MARK: Internal

    var credentials: AppCredentials {
        AppCredentials(clientId: key, clientPassword: secret, scopes: [], callbackURL: callbackUrl)
    }

}
