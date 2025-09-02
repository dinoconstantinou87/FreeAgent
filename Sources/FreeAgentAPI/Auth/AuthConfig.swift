import Foundation

public struct AuthConfig: Sendable {
    public let key: String
    public let secret: String
    public let environment: Environment

    public init(key: String, secret: String, environment: Environment) {
        self.key = key
        self.secret = secret
        self.environment = environment
    }
}
