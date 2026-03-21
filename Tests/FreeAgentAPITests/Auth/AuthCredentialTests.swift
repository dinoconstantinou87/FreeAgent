import Foundation
import Testing

@testable import FreeAgentAPI

struct AuthCredentialTests {

    @Test("has not expired when expiresAt is nil")
    func hasNotExpiredWhenNil() {
        let credential = AuthCredential(
            token: "token",
            refreshToken: "refresh",
            expiresAt: nil,
            environment: .sandbox
        )

        #expect(!credential.hasExpired())
    }

    @Test("has not expired when expiresAt is in the future")
    func hasNotExpiredWhenFuture() {
        let credential = AuthCredential(
            token: "token",
            refreshToken: "refresh",
            expiresAt: Date.now.addingTimeInterval(3600),
            environment: .sandbox
        )

        #expect(!credential.hasExpired())
    }

    @Test("has expired when expiresAt is in the past")
    func hasExpiredWhenPast() {
        let credential = AuthCredential(
            token: "token",
            refreshToken: "refresh",
            expiresAt: Date.now.addingTimeInterval(-3600),
            environment: .sandbox
        )

        #expect(credential.hasExpired())
    }

    @Test("is encodable and decodable")
    func codable() throws {
        let credential = AuthCredential(
            token: "token",
            refreshToken: "refresh",
            expiresAt: Date(timeIntervalSince1970: 1_000_000),
            environment: .production
        )

        let data = try JSONEncoder().encode(credential)
        let decoded = try JSONDecoder().decode(AuthCredential.self, from: data)

        #expect(decoded.token == credential.token)
        #expect(decoded.refreshToken == credential.refreshToken)
        #expect(decoded.expiresAt == credential.expiresAt)
        #expect(decoded.environment == credential.environment)
    }
}
