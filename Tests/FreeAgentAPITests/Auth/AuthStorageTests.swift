import Configuration
import Foundation
import Mockable
import Testing

@testable import FreeAgentAPI

struct AuthStorageTests {

    // MARK: Internal

    @Test("get returns nil when the store has no data")
    func getReturnsNilWhenEmpty() throws {
        given(store).read().willReturn(nil)

        let storage = AuthStorage(store: store)
        let result = try storage.get()

        #expect(result == nil)
    }

    @Test("get returns decoded credential from the store")
    func getReturnsCredential() throws {
        let credential = AuthCredential(
            token: "token",
            refreshToken: "refresh",
            expiresAt: Date(timeIntervalSince1970: 1_000_000),
            environment: .sandbox
        )
        let data = try JSONEncoder().encode(credential)
        given(store).read().willReturn(data)

        let storage = AuthStorage(store: store)
        let result = try storage.get()

        #expect(result?.token == "token")
        #expect(result?.refreshToken == "refresh")
        #expect(result?.environment == .sandbox)
    }

    @Test("get throws when the stored data is corrupted")
    func getThrowsOnCorruptedData() {
        given(store).read().willReturn(Data("not json".utf8))

        let storage = AuthStorage(store: store)

        #expect(throws: DecodingError.self) {
            try storage.get()
        }
    }

    @Test("set encodes credential and writes it to the store")
    func setStoresCredential() throws {
        given(store).write(.any).willReturn()

        let storage = AuthStorage(store: store)
        let credential = AuthCredential(
            token: "token",
            refreshToken: "refresh",
            expiresAt: nil,
            environment: .production
        )

        try storage.set(credential)

        verify(store)
            .write(.matching { data in
                let written = try? JSONDecoder().decode(AuthCredential.self, from: data)
                return written?.token == "token" && written?.environment == .production
            })
            .called(.once)
    }

    @Test("clear removes credential from the store")
    func clearRemovesCredential() throws {
        given(store).remove().willReturn()

        let storage = AuthStorage(store: store)

        try storage.clear()

        verify(store).remove().called(.once)
    }

    @Test("reads the credential store from the config", arguments: CredentialStoreKind.allCases)
    func readsCredentialStore(kind: CredentialStoreKind) throws {
        let config = ConfigReader(provider: InMemoryProvider(values: ["credentialStore": .init(stringLiteral: kind.rawValue)]))

        #expect(throws: Never.self) {
            try AuthStorage(config: config)
        }
    }

    @Test("uses the platform's store when the config names none")
    func defaultsCredentialStore() {
        let config = ConfigReader(provider: InMemoryProvider(values: [:]))

        #expect(throws: Never.self) {
            try AuthStorage(config: config)
        }
    }

    @Test("throws when the config names an unknown credential store")
    func throwsForUnknownCredentialStore() {
        let config = ConfigReader(provider: InMemoryProvider(values: ["credentialStore": "vault"]))

        #expect(throws: (any Error).self) {
            try AuthStorage(config: config)
        }
    }

    // MARK: Private

    private let store = MockCredentialStoreInterface()

}
