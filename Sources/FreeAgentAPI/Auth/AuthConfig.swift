import Configuration
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

    public init(config: ConfigReader) throws {
        try self.init(
            key: config.requiredString(forKey: "key"),
            secret: config.requiredString(forKey: "secret", isSecret: true),
            callbackUrl: config.requiredString(forKey: "callbackUrl", as: URL.self),
            environment: config.requiredString(forKey: "environment", as: Environment.self)
        )
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
