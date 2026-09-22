import Foundation
import OAuthenticator
import OpenAPIRuntime
import OpenAPIURLSession

public struct AuthClient: Sendable {

    // MARK: Lifecycle

    public init(
        config: AuthConfig,
        storage: any AuthStorageInterface = AuthStorage(),
        userAuthenticator: @escaping UserAuthenticator = { _, _ in throw AuthError.unauthenticated },
        transport: any ClientTransport = URLSessionTransport()
    ) {
        authenticator = Authenticator(
            config: Authenticator.Configuration(
                appCredentials: config.credentials,
                loginStorage: .backed(by: storage, environment: config.environment),
                tokenHandling: AuthProvider.tokenHandling(
                    with: .init(environment: config.environment),
                    transport: transport
                ),
                mode: .manualOnly,
                userAuthenticator: userAuthenticator
            )
        )

        self.storage = storage
        environment = config.environment
    }

    // MARK: Public

    public typealias UserAuthenticator = Authenticator.UserAuthenticator

    public func token() async throws -> String {
        try await authenticator.login().accessToken.value
    }

    @discardableResult
    public func authorize() async throws -> AuthCredential {
        try storage.clear()

        return AuthCredential(login: try await authenticator.login(), environment: environment)
    }

    // MARK: Private

    private let authenticator: Authenticator
    private let storage: any AuthStorageInterface
    private let environment: Environment

}
