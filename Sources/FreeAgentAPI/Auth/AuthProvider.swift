import Foundation
import OAuthenticator
import OpenAPIRuntime
import OpenAPIURLSession

public enum AuthProvider {

    // MARK: Public

    public struct UserTokenParameters: Sendable {

        public init(environment: Environment) {
            self.environment = environment
        }

        public let environment: Environment

    }

    public static func tokenHandling(
        with parameters: UserTokenParameters,
        transport: any ClientTransport = URLSessionTransport()
    ) -> TokenHandling {
        let client = Client(serverURL: parameters.environment.baseURL, transport: transport)

        return TokenHandling(
            authorizationURLProvider: authorizationURLProvider(with: parameters),
            loginProvider: loginProvider(with: client),
            refreshProvider: refreshProvider(with: client)
        )
    }

    // MARK: Internal

    static func authorizationURLProvider(
        with parameters: UserTokenParameters
    ) -> TokenHandling.AuthorizationURLProvider {
        { params in
            var urlBuilder = URLComponents(
                url: parameters.environment.url("v2/approve_app"),
                resolvingAgainstBaseURL: false
            )

            urlBuilder?.queryItems = [
                URLQueryItem(name: "client_id", value: params.credentials.clientId),
                URLQueryItem(name: "redirect_uri", value: params.credentials.callbackURL.absoluteString),
                URLQueryItem(name: "response_type", value: "code"),
                URLQueryItem(name: "state", value: params.stateToken),
            ]

            guard let url = urlBuilder?.url else {
                throw AuthError.unexpected(status: nil)
            }

            return url
        }
    }

    static func authorizationCodeGrant(
        redirect: URL,
        stateToken: String,
        appCredentials: AppCredentials
    ) throws -> Components.Schemas.AuthorizationCodeGrant {
        if let error = redirect.queryValues(named: "error").first {
            throw AuthError.declined(
                error: error,
                description: redirect.queryValues(named: "error_description").first
            )
        }

        guard redirect.queryValues(named: "state").first == stateToken else {
            throw AuthError.declined(error: "invalid_state", description: nil)
        }

        return Components.Schemas.AuthorizationCodeGrant(
            grantType: "authorization_code",
            code: try redirect.authorizationCode,
            redirectUri: appCredentials.callbackURL.absoluteString,
            clientId: appCredentials.clientId,
            clientSecret: appCredentials.clientPassword
        )
    }

    static func refreshTokenGrant(
        login: Login,
        appCredentials: AppCredentials
    ) throws -> Components.Schemas.RefreshTokenGrant {
        guard let refreshToken = login.refreshToken, !refreshToken.value.isEmpty else {
            throw AuthError.unauthenticated
        }

        return Components.Schemas.RefreshTokenGrant(
            grantType: "refresh_token",
            refreshToken: refreshToken.value,
            clientId: appCredentials.clientId,
            clientSecret: appCredentials.clientPassword
        )
    }

    static func loginProvider(with client: Client) -> TokenHandling.LoginProvider {
        { params in
            let grant = try authorizationCodeGrant(
                redirect: params.redirectURL,
                stateToken: params.stateToken,
                appCredentials: params.credentials
            )

            return try await login(
                from: client.tokenEndpoint(body: .json(.authorizationCode(grant))),
                carryingOver: nil
            )
        }
    }

    static func refreshProvider(with client: Client) -> TokenHandling.RefreshProvider {
        { existing, appCredentials, _ in
            let grant = try refreshTokenGrant(login: existing, appCredentials: appCredentials)

            return try await login(
                from: client.tokenEndpoint(body: .json(.refreshToken(grant))),
                carryingOver: existing.refreshToken
            )
        }
    }

    // MARK: Private

    private static func login(
        from output: Operations.TokenEndpoint.Output,
        carryingOver existing: Token?
    ) throws -> Login {
        switch output {
        case .ok(let success):
            let response = try success.body.json

            return Login(
                accessToken: response.expiresIn
                    .map { Token(value: response.accessToken, expiresIn: $0) }
                    ?? Token(value: response.accessToken),
                refreshToken: response.refreshToken.map { Token(value: $0) } ?? existing
            )

        case .default(let statusCode, let failure):
            switch failure.body {
            case .json(let error): throw AuthError.denied(error)
            case .plainText: throw AuthError.unexpected(status: statusCode)
            }
        }
    }

}
