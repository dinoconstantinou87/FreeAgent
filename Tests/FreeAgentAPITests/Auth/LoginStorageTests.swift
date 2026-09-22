import Foundation
import Mockable
import OAuthenticator
import Testing

@testable import FreeAgentAPI

struct LoginStorageTests {

    @Test("stores a valid login against the configured environment")
    func storesValidLogin() async throws {
        let storage = MockAuthStorageInterface()
        given(storage).set(.any).willReturn()

        try await LoginStorage.backed(by: storage, environment: .sandbox).storeLogin(
            Login(accessToken: Token(value: "the-token"), refreshToken: Token(value: "the-refresh"))
        )

        verify(storage)
            .set(.matching { credential in
                credential.token == "the-token"
                    && credential.refreshToken == "the-refresh"
                    && credential.environment == .sandbox
            })
            .called(.once)
    }

    @Test("writes nothing when asked to store an invalidated login")
    func ignoresInvalidatedLogin() async throws {
        let storage = MockAuthStorageInterface()
        given(storage).set(.any).willReturn()

        try await LoginStorage.backed(by: storage, environment: .sandbox).storeLogin(
            Login(token: "invalid", validUntilDate: .distantPast)
        )

        verify(storage).set(.any).called(.never)
    }

    @Test("reads the stored credential as a login")
    func readsStoredCredential() async throws {
        let storage = MockAuthStorageInterface()
        given(storage).get().willReturn(
            AuthCredential(
                token: "stored-token",
                refreshToken: "stored-refresh",
                expiresAt: nil,
                environment: .sandbox
            )
        )

        let login = try await LoginStorage.backed(by: storage, environment: .sandbox).retrieveLogin()

        #expect(login?.accessToken.value == "stored-token")
        #expect(login?.refreshToken?.value == "stored-refresh")
    }

}
