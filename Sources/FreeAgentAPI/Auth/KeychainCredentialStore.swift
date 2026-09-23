#if os(macOS)
import Foundation
@preconcurrency import KeychainAccess

public struct KeychainCredentialStore: CredentialStoreInterface {

    // MARK: Lifecycle

    public init(keychain: any KeychainInterface = Keychain(service: "freeagent.cli")) {
        self.keychain = keychain
    }

    // MARK: Public

    public func read() throws -> Data? {
        try keychain.getData(key, ignoringAttributeSynchronizable: true)
    }

    public func write(_ data: Data) throws {
        try keychain.set(data, key: key, ignoringAttributeSynchronizable: true)
    }

    public func remove() throws {
        try keychain.remove(key, ignoringAttributeSynchronizable: true)
    }

    // MARK: Private

    private let keychain: any KeychainInterface
    private let key = "freeagent.cli.credential"

}
#endif
