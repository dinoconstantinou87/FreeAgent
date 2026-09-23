#if os(macOS)
import Foundation
@preconcurrency import KeychainAccess

// MARK: - KeychainCredentialStore

public struct KeychainCredentialStore: CredentialStoreInterface {

    // MARK: Lifecycle

    public init() { }

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

    private let keychain = Keychain(service: "freeagent.cli")
    private let key = "freeagent.cli.credential"

}

// MARK: - Keychain + @retroactive @unchecked Sendable

// swiftlint:disable:next no_unchecked_sendable
extension Keychain: @retroactive @unchecked Sendable { }
#endif
