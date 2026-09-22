import Configuration
import Foundation

// MARK: - AuthStorage

public struct AuthStorage: AuthStorageInterface {

    // MARK: Lifecycle

    #if os(macOS)
    public init(
        variables: any ConfigProvider = AuthStorage.defaultVariables,
        keychain: KeychainProvider? = KeychainProvider(),
        file: CredentialFile = CredentialFile()
    ) {
        self.variables = variables
        self.keychain = keychain
        self.file = file
    }
    #else
    public init(
        variables: any ConfigProvider = AuthStorage.defaultVariables,
        file: CredentialFile = CredentialFile()
    ) {
        self.variables = variables
        self.file = file
    }
    #endif

    // MARK: Public

    public static var defaultVariables: any ConfigProvider {
        EnvironmentVariablesProvider().prefixKeys(with: "freeagent")
    }

    public func get() async throws -> AuthCredential? {
        let reader = ConfigReader(providers: await providers())

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
        let data = try JSONEncoder().encode(credential)

        #if os(macOS)
        if let keychain {
            try keychain.write(data)
            return
        }
        #endif

        try file.write(data)
    }

    public func clear() throws {
        var failure: (any Error)?

        #if os(macOS)
        if let keychain {
            do {
                try keychain.remove()
            } catch {
                failure = failure ?? error
            }
        }
        #endif

        do {
            try file.remove()
        } catch {
            failure = failure ?? error
        }

        if let failure {
            throw failure
        }
    }

    // MARK: Private

    private let variables: any ConfigProvider
    private let file: CredentialFile

    #if os(macOS)
    private let keychain: KeychainProvider?
    #endif

    private func providers() async -> [any ConfigProvider] {
        var providers: [any ConfigProvider] = [variables]

        #if os(macOS)
        if let keychain {
            providers.append(keychain)
        }
        #endif

        if let stored = try? await JSONProvider(filePath: file.path) {
            providers.append(stored)
        }

        return providers
    }

}
