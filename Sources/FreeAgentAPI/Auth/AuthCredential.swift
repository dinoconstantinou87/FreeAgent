import Foundation

public struct AuthCredential: Codable, Sendable {
    public let token: String
    public let refreshToken: String
    public let expiresAt: Date?
    public let environment: Environment

    public func hasExpired() -> Bool {
        guard let expiresAt else {
            return false
        }

        return expiresAt < .now
    }
}
