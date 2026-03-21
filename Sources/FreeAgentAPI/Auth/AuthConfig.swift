import Foundation

public struct AuthConfig: Sendable {
    public init(key: String, secret: String, environment: Environment) {
        self.key = key
        self.secret = secret
        self.environment = environment
    }

    public let key: String
    public let secret: String
    public let environment: Environment

}
