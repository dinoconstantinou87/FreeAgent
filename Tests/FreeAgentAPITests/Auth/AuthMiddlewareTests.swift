import Foundation
import HTTPTypes
import Mockable
import OpenAPIRuntime
import Testing

@testable import FreeAgentAPI

struct AuthMiddlewareTests {

    // MARK: Internal

    @Test("adds bearer token to request")
    func addsBearerToken() async throws {
        let storage = MockAuthStorageInterface()
        given(storage).get().willReturn(
            AuthCredential(
                token: "stored-token",
                refreshToken: "stored-refresh",
                expiresAt: Date.now.addingTimeInterval(3600),
                environment: .sandbox
            )
        )

        let (response, _) = try await intercept(storage: storage) { request, body, _ in
            #expect(request.headerFields[.authorization] == "Bearer stored-token")
            return (HTTPResponse(status: .ok), body)
        }

        #expect(response.status == .ok)
    }

    @Test("throws an unauthenticated error when no credential is stored")
    func throwsWhenNoCredential() async throws {
        let storage = MockAuthStorageInterface()
        given(storage).get().willReturn(nil)

        await #expect(throws: AuthError.unauthenticated) {
            try await intercept(storage: storage) { _, body, _ in
                (HTTPResponse(status: .ok), body)
            }
        }
    }

    // MARK: Private

    private let baseURL = URL(string: "https://api.example.com")!

    private let config = AuthConfig(
        key: "the-key",
        secret: "the-secret",
        callbackUrl: URL(string: "http://localhost:8080/callback")!,
        environment: .sandbox
    )

    private func intercept(
        storage: MockAuthStorageInterface,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let middleware = AuthMiddleware(client: AuthClient(config: config, storage: storage))

        return try await middleware.intercept(
            HTTPRequest(method: .get, scheme: "https", authority: "api.example.com", path: "/test"),
            body: nil,
            baseURL: baseURL,
            operationID: "test",
            next: next
        )
    }

}
