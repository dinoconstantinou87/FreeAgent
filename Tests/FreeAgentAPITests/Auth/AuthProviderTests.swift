import Foundation
import HTTPTypes
import Mockable
import OAuthenticator
import OpenAPIRuntime
import Testing

@testable import FreeAgentAPI

struct AuthProviderTests {

    // MARK: Internal

    @Test("builds the authorization code grant from the redirect")
    func buildsAuthorizationCodeGrant() throws {
        let redirect = try #require(URL(string: "http://localhost:8080/callback?code=the-code&state=the-state"))
        let grant = try AuthProvider.authorizationCodeGrant(
            redirect: redirect,
            stateToken: "the-state",
            appCredentials: credentials
        )

        #expect(grant.grantType == "authorization_code")
        #expect(grant.code == "the-code")
        #expect(grant.redirectUri == callbackUrl.absoluteString)
        #expect(grant.clientId == "the-key")
        #expect(grant.clientSecret == "the-secret")
    }

    @Test("throws when the redirect carries an error")
    func throwsWhenRedirectCarriesError() throws {
        let redirect = try #require(URL(
            string: "http://localhost:8080/callback?error=access_denied&error_description=The%20user%20said%20no"
        ))

        #expect(throws: AuthError.declined(error: "access_denied", description: "The user said no")) {
            try AuthProvider.authorizationCodeGrant(
                redirect: redirect,
                stateToken: "the-state",
                appCredentials: credentials
            )
        }
    }

    @Test("throws when the redirect state does not match")
    func throwsWhenStateMismatched() throws {
        let redirect = try #require(URL(string: "http://localhost:8080/callback?code=the-code&state=not-the-state"))

        #expect(throws: AuthError.declined(error: "invalid_state", description: nil)) {
            try AuthProvider.authorizationCodeGrant(
                redirect: redirect,
                stateToken: "the-state",
                appCredentials: credentials
            )
        }
    }

    @Test("builds the refresh token grant from the stored login")
    func buildsRefreshTokenGrant() throws {
        let login = Login(accessToken: Token(value: "access"), refreshToken: Token(value: "the-refresh"))
        let grant = try AuthProvider.refreshTokenGrant(login: login, appCredentials: credentials)

        #expect(grant.grantType == "refresh_token")
        #expect(grant.refreshToken == "the-refresh")
        #expect(grant.clientId == "the-key")
        #expect(grant.clientSecret == "the-secret")
    }

    @Test("throws when there is no refresh token to send")
    func throwsWithoutRefreshToken() {
        #expect(throws: AuthError.unauthenticated) {
            try AuthProvider.refreshTokenGrant(
                login: Login(accessToken: Token(value: "access")),
                appCredentials: credentials
            )
        }
    }

    @Test("maps a token response onto a login")
    func mapsTokenResponse() async throws {
        let login = try await refresh(transport())

        #expect(login.accessToken.value == "the-access-token")
        #expect(login.refreshToken?.value == "the-refresh-token")
        #expect(login.accessToken.expiry != nil)
    }

    @Test("leaves the expiry nil when the response has no expires in")
    func leavesExpiryNil() async throws {
        let body = #"{"access_token":"the-access-token","refresh_token":"the-refresh-token"}"#
        let login = try await refresh(transport(body))

        #expect(login.accessToken.expiry == nil)
    }

    @Test("keeps the existing refresh token when the response omits one")
    func carriesOverRefreshToken() async throws {
        let body = #"{"access_token":"refreshed","expires_in":604800}"#
        let login = try await refresh(transport(body))

        #expect(login.refreshToken?.value == "the-refresh")
    }

    @Test("surfaces a rejected token response")
    func surfacesTokenRejection() async throws {
        await #expect(throws: AuthError.denied(.init(error: "invalid_grant"))) {
            try await refresh(transport(#"{"error":"invalid_grant"}"#, status: .badRequest))
        }
    }

    @Test("surfaces a plain text token rejection")
    func surfacesPlainTextRejection() async throws {
        let rejection = transport(
            "HTTP Basic: Access denied.",
            status: .unauthorized,
            contentType: "text/plain"
        )

        await #expect(throws: AuthError.unexpected(status: 401)) {
            try await refresh(rejection)
        }
    }

    // MARK: Private

    private static let tokenBody = """
        {"access_token":"the-access-token","refresh_token":"the-refresh-token","expires_in":604800}
        """

    private let callbackUrl = URL(string: "http://localhost:8080/callback")!

    private var credentials: AppCredentials {
        AppCredentials(
            clientId: "the-key",
            clientPassword: "the-secret",
            scopes: [],
            callbackURL: callbackUrl
        )
    }

    private func transport(
        _ body: String = tokenBody,
        status: HTTPResponse.Status = .ok,
        contentType: String = "application/json"
    ) -> MockClientTransportInterface {
        let response = HTTPResponse(status: status, headerFields: [.contentType: contentType])
        let transport = MockClientTransportInterface()

        given(transport)
            .send(.any, body: .any, baseURL: .any, operationID: .any)
            .willReturn((response, HTTPBody(Data(body.utf8))))

        return transport
    }

    private func refresh(_ transport: MockClientTransportInterface) async throws -> Login {
        let provider = AuthProvider.refreshProvider(
            with: Client(serverURL: Environment.sandbox.baseURL, transport: transport)
        )

        return try await provider(
            Login(accessToken: Token(value: "stale"), refreshToken: Token(value: "the-refresh")),
            credentials,
            { _ in (Data(), URLResponse()) }
        )
    }

}
