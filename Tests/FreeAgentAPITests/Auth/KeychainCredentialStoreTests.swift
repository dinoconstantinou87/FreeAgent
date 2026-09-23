#if os(macOS)
import Foundation
import Mockable
import Testing

@testable import FreeAgentAPI

struct KeychainCredentialStoreTests {

    // MARK: Internal

    @Test("read returns nil when the keychain has no credential")
    func readReturnsNilWhenMissing() throws {
        given(keychain).getData(.any, ignoringAttributeSynchronizable: .any).willReturn(nil)

        #expect(try store.read() == nil)
    }

    @Test("read returns the credential item ignoring synchronizable")
    func readReturnsCredential() throws {
        given(keychain)
            .getData(.value("freeagent.cli.credential"), ignoringAttributeSynchronizable: .value(true))
            .willReturn(Data("credential".utf8))

        #expect(try store.read() == Data("credential".utf8))
    }

    @Test("write stores the data under the credential key ignoring synchronizable")
    func writeStoresCredential() throws {
        given(keychain).set(.any, key: .any, ignoringAttributeSynchronizable: .any).willReturn()

        try store.write(Data("credential".utf8))

        verify(keychain)
            .set(
                .value(Data("credential".utf8)),
                key: .value("freeagent.cli.credential"),
                ignoringAttributeSynchronizable: .value(true)
            )
            .called(.once)
    }

    @Test("remove deletes the credential item ignoring synchronizable")
    func removeDeletesCredential() throws {
        given(keychain).remove(.any, ignoringAttributeSynchronizable: .any).willReturn()

        try store.remove()

        verify(keychain)
            .remove(.value("freeagent.cli.credential"), ignoringAttributeSynchronizable: .value(true))
            .called(.once)
    }

    // MARK: Private

    private let keychain = MockKeychainInterface()

    private var store: KeychainCredentialStore {
        KeychainCredentialStore(keychain: keychain)
    }

}
#endif
