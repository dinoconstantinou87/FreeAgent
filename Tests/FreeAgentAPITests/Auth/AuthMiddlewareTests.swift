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
        let credential = AuthCredential(
            token: "test-token",
            refreshToken: "refresh",
            expiresAt: Date.now.addingTimeInterval(3600),
            environment: .sandbox
        )
        given(storage).get().willReturn(credential)

        let middleware = AuthMiddleware(config: config, storage: storage)
        let request = HTTPRequest(method: .get, scheme: "https", authority: "api.example.com", path: "/test")

        let (response, _) = try await middleware.intercept(
            request,
            body: nil,
            baseURL: try #require(URL(string: "https://api.example.com")),
            operationID: "test"
        ) { request, body, _ in
            #expect(request.headerFields[.authorization] == "Bearer test-token")
            return (HTTPResponse(status: .ok), body)
        }

        #expect(response.status == .ok)
    }

    @Test("throws when no credential is stored")
    func throwsWhenNoCredential() async throws {
        let storage = MockAuthStorageInterface()
        given(storage).get().willReturn(nil)

        let middleware = AuthMiddleware(config: config, storage: storage)
        let request = HTTPRequest(method: .get, scheme: "https", authority: "api.example.com", path: "/test")

        await #expect(throws: AuthMiddlewareError.self) {
            try await middleware.intercept(
                request,
                body: nil,
                baseURL: try #require(URL(string: "https://api.example.com")),
                operationID: "test"
            ) { _, body, _ in
                (HTTPResponse(status: .ok), body)
            }
        }
    }

    // MARK: Private

    private let config = AuthConfig(key: "key", secret: "secret", environment: .sandbox)

}
