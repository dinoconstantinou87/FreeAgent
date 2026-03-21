import Foundation
import Mockable
import Testing

@testable import FreeAgentAPI

@Suite("AuthStorage")
struct AuthStorageTests {

    private let keychain = MockKeychainInterface()

    @Test("get returns nil when keychain has no data")
    func getReturnsNilWhenEmpty() throws {
        given(keychain).getData(.any).willReturn(nil)

        let storage = AuthStorage(keychain: keychain)
        let result = try storage.get()

        #expect(result == nil)
    }

    @Test("get returns decoded credential from keychain")
    func getReturnsCredential() throws {
        let credential = AuthCredential(
            token: "token",
            refreshToken: "refresh",
            expiresAt: Date(timeIntervalSince1970: 1_000_000),
            environment: .sandbox
        )
        let data = try JSONEncoder().encode(credential)
        given(keychain).getData(.any).willReturn(data)

        let storage = AuthStorage(keychain: keychain)
        let result = try storage.get()

        #expect(result?.token == "token")
        #expect(result?.refreshToken == "refresh")
        #expect(result?.environment == .sandbox)
    }

    @Test("get throws when keychain data is corrupted")
    func getThrowsOnCorruptedData() {
        given(keychain).getData(.any).willReturn(Data("not json".utf8))

        let storage = AuthStorage(keychain: keychain)

        #expect(throws: DecodingError.self) {
            try storage.get()
        }
    }

    @Test("set encodes credential and stores in keychain")
    func setStoresCredential() throws {
        given(keychain).set(.any, key: .any).willReturn()

        let storage = AuthStorage(keychain: keychain)
        let credential = AuthCredential(
            token: "token",
            refreshToken: "refresh",
            expiresAt: nil,
            environment: .production
        )

        try storage.set(credential)

        verify(keychain).set(.any, key: .value("freeagent.cli.credential")).called(.once)
    }

    @Test("clear removes credential from keychain")
    func clearRemovesCredential() throws {
        given(keychain).remove(.any).willReturn()

        let storage = AuthStorage(keychain: keychain)

        try storage.clear()

        verify(keychain).remove(.value("freeagent.cli.credential")).called(.once)
    }
}
