import Foundation
import Mockable
import OAuthenticator
import Synchronization
import Testing

@testable import FreeAgentAPI

struct LoginStorageTests {

    @Test("stores a valid login against the configured environment")
    func storesValidLogin() async throws {
        let stored = Mutex([AuthCredential]())
        let storage = MockAuthStorageInterface()
        given(storage).set(.any).willProduce { credential in stored.withLock { $0.append(credential) } }

        try await LoginStorage.backed(by: storage, environment: .sandbox).storeLogin(
            Login(accessToken: Token(value: "the-token"), refreshToken: Token(value: "the-refresh"))
        )

        let credential = stored.withLock(\.first)
        #expect(credential?.token == "the-token")
        #expect(credential?.refreshToken == "the-refresh")
        #expect(credential?.environment == .sandbox)
    }

    @Test("writes nothing when asked to store an invalidated login")
    func ignoresInvalidatedLogin() async throws {
        let stored = Mutex([AuthCredential]())
        let storage = MockAuthStorageInterface()
        given(storage).set(.any).willProduce { credential in stored.withLock { $0.append(credential) } }

        try await LoginStorage.backed(by: storage, environment: .sandbox).storeLogin(
            Login(token: "invalid", validUntilDate: .distantPast)
        )

        let written = stored.withLock { $0 }
        #expect(written.isEmpty)
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
