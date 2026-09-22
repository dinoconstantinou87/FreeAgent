import Configuration
import Foundation

// MARK: - AuthStorage

public struct AuthStorage: AuthStorageInterface {

    // MARK: Lifecycle

    public init(
        variables: any ConfigProvider = AuthStorage.defaultVariables,
        store: CredentialStore = .default
    ) {
        self.variables = variables
        self.store = store
    }

    // MARK: Public

    public static var defaultVariables: any ConfigProvider {
        EnvironmentVariablesProvider().prefixKeys(with: "freeagent")
    }

    public func get() async throws -> AuthCredential? {
        let reader = ConfigReader(providers: [variables] + [await store.provider()].compactMap { $0 })

        guard let token = reader.string(forKey: "token", isSecret: true), !token.isEmpty else {
            return nil
        }

        return AuthCredential(
            token: token,
            refreshToken: reader.string(forKey: "refreshToken", isSecret: true),
            expiresAt: reader.double(forKey: "expiresAt").map(Date.init(timeIntervalSinceReferenceDate:)),
            environment: reader.string(forKey: "environment", as: Environment.self, default: .production)
        )
    }

    public func set(_ credential: AuthCredential) throws {
        try store.write(try JSONEncoder().encode(credential))
    }

    public func clear() throws {
        try store.remove()
    }

    // MARK: Private

    private let variables: any ConfigProvider
    private let store: CredentialStore

}
