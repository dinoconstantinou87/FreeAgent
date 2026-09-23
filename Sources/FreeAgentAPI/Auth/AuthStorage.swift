import Foundation

public struct AuthStorage: AuthStorageInterface {

    // MARK: Lifecycle

    #if os(macOS)
    public init(store: any CredentialStoreInterface = KeychainCredentialStore()) {
        self.store = store
    }
    #else
    public init(store: any CredentialStoreInterface = FileCredentialStore()) {
        self.store = store
    }
    #endif

    // MARK: Public

    public func get() throws -> AuthCredential? {
        try store.read()
            .map { data in
                try JSONDecoder().decode(AuthCredential.self, from: data)
            }
    }

    public func set(_ credential: AuthCredential) throws {
        let data = try JSONEncoder().encode(credential)
        try store.write(data)
    }

    public func clear() throws {
        try store.remove()
    }

    // MARK: Private

    private let store: any CredentialStoreInterface

}
