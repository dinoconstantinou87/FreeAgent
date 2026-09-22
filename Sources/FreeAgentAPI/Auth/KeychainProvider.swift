#if os(macOS)
import Configuration
import Foundation
@preconcurrency import KeychainAccess

// MARK: - KeychainProvider

public struct KeychainProvider: Sendable {

    // MARK: Lifecycle

    public init(service: String = "freeagent.cli", key: String = KeychainProvider.credentialKey) {
        keychain = Keychain(service: service)
        self.key = key
    }

    // MARK: Public

    public static let credentialKey = "freeagent.cli.credential"

    public func write(_ data: Data) throws {
        try keychain.set(data, key: key, ignoringAttributeSynchronizable: true)
    }

    public func remove() throws {
        try keychain.remove(key, ignoringAttributeSynchronizable: true)
    }

    // MARK: Private

    private let keychain: Keychain
    private let key: String

    private var storedData: Data? {
        try? keychain.getData(key, ignoringAttributeSynchronizable: true)
    }

}

// MARK: ConfigProvider

extension KeychainProvider: ConfigProvider {
    public var providerName: String {
        "KeychainProvider"
    }

    public func value(forKey key: AbsoluteConfigKey, type: ConfigType) throws -> LookupResult {
        Snapshot(credential: storedCredential).value(forKey: key, type: type)
    }

    public func fetchValue(forKey key: AbsoluteConfigKey, type: ConfigType) async throws -> LookupResult {
        try value(forKey: key, type: type)
    }

    public func watchValue<Return>(
        forKey key: AbsoluteConfigKey,
        type: ConfigType,
        updatesHandler: (ConfigUpdatesAsyncSequence<Result<LookupResult, any Error>, Never>) async throws -> Return
    ) async throws -> Return {
        try await watchValueFromValue(forKey: key, type: type, updatesHandler: updatesHandler)
    }

    public func snapshot() -> any ConfigSnapshotProtocol {
        Snapshot(credential: storedCredential)
    }

    public func watchSnapshot<Return>(
        updatesHandler: (ConfigUpdatesAsyncSequence<any ConfigSnapshotProtocol, Never>) async throws -> Return
    ) async throws -> Return {
        try await watchSnapshotFromSnapshot(updatesHandler: updatesHandler)
    }
}

// MARK: KeychainProvider.Snapshot

extension KeychainProvider {

    // MARK: Internal

    struct Snapshot: ConfigSnapshotProtocol {

        // MARK: Internal

        let credential: AuthCredential?

        var providerName: String {
            "KeychainProvider"
        }

        func value(forKey key: AbsoluteConfigKey, type: ConfigType) -> LookupResult {
            LookupResult(encodedKey: key.description, value: configValue(forKey: key, type: type))
        }

        // MARK: Private

        private func configValue(forKey key: AbsoluteConfigKey, type: ConfigType) -> ConfigValue? {
            guard let credential, let field = key.components.last else {
                return nil
            }

            switch (field, type) {
            case ("token", .string):
                return ConfigValue(.string(credential.token), isSecret: true)

            case ("refreshToken", .string):
                return credential.refreshToken.map { ConfigValue(.string($0), isSecret: true) }

            case ("expiresAt", .double):
                return credential.expiresAt
                    .map { ConfigValue(.double($0.timeIntervalSinceReferenceDate), isSecret: false) }

            case ("environment", .string):
                return ConfigValue(.string(credential.environment.rawValue), isSecret: false)

            default:
                return nil
            }
        }

    }

    // MARK: Fileprivate

    fileprivate var storedCredential: AuthCredential? {
        guard let storedData else {
            return nil
        }

        return try? JSONDecoder().decode(AuthCredential.self, from: storedData)
    }

}
#endif
