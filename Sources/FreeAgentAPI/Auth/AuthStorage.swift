import Foundation
@preconcurrency import KeychainAccess

public struct AuthStorage: Sendable {

    // MARK: Lifecycle

    public init() { }

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

    private let keychain = Keychain(service: "freeagent.cli")
    private let key = "freeagent.cli.credential"

}
