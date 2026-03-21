import Foundation
@preconcurrency import KeychainAccess

// MARK: - AuthStorage

public struct AuthStorage: AuthStorageInterface {

    // MARK: Lifecycle

    public init(keychain: any KeychainInterface = Keychain(service: "freeagent.cli")) {
        self.keychain = keychain
    }

    // MARK: Public

    public func get() throws -> AuthCredential? {
        try keychain.getData(key)
            .map { data in
                try JSONDecoder().decode(AuthCredential.self, from: data)
            }
    }

    public func set(_ credential: AuthCredential) throws {
        let data = try JSONEncoder().encode(credential)
        try keychain.set(data, key: key)
    }

    public func clear() throws {
        try keychain.remove(key)
    }

    // MARK: Private

    private let keychain: any KeychainInterface
    private let key = "freeagent.cli.credential"

}

// MARK: - Keychain + @retroactive @unchecked Sendable

// swiftlint:disable:next no_unchecked_sendable
extension Keychain: @retroactive @unchecked Sendable { }

// MARK: - Keychain + KeychainInterface

extension Keychain: KeychainInterface {
    public func getData(_ key: String) throws -> Data? {
        try getData(key, ignoringAttributeSynchronizable: true)
    }

    public func set(_ value: Data, key: String) throws {
        try set(value, key: key, ignoringAttributeSynchronizable: true)
    }

    public func remove(_ key: String) throws {
        try remove(key, ignoringAttributeSynchronizable: true)
    }
}
