import Foundation
import Testing

@testable import FreeAgentAPI

struct AuthCredentialTests {

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

    @Test("decodes a credential stored without a refresh token")
    func decodesWithoutRefreshToken() throws {
        let data = Data(#"{"token":"token","environment":"sandbox"}"#.utf8)
        let decoded = try JSONDecoder().decode(AuthCredential.self, from: data)

        #expect(decoded.refreshToken == nil)
        #expect(decoded.expiresAt == nil)
    }

    @Test("carries the expiry onto the login it bridges to")
    func bridgesExpiryToLogin() {
        let expiresAt = Date(timeIntervalSince1970: 1_000_000)
        let credential = AuthCredential(
            token: "token",
            refreshToken: "refresh",
            expiresAt: expiresAt,
            environment: .sandbox
        )

        #expect(credential.login.accessToken.expiry == expiresAt)
        #expect(credential.login.accessToken.valid == false)
        #expect(credential.login.refreshToken?.value == "refresh")
    }

    @Test("bridges to a login that never expires when there is no expiry")
    func bridgesMissingExpiryToLogin() {
        let credential = AuthCredential(
            token: "token",
            refreshToken: nil,
            expiresAt: nil,
            environment: .sandbox
        )

        #expect(credential.login.accessToken.valid)
        #expect(credential.login.refreshToken == nil)
    }

}
