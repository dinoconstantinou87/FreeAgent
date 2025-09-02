import Foundation
import OpenAPIRuntime
import HTTPTypes

public struct AuthMiddleware: ClientMiddleware {
    let config: AuthConfig
    let storage = AuthStorage()

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let credential = try await credential()
        var request = request
        request.headerFields[.authorization] = "Bearer \(credential.token)"

        return try await next(request, body, baseURL)
    }

    private func credential() async throws -> AuthCredential {
        guard let credential = try storage.get() else {
            throw AuthMiddlewareError.noCredentialFound
        }

        guard !credential.hasExpired() else {
            let client = AuthClient(config: config)
            return try await client.refresh()
        }

        return credential
    }
}

public extension ClientMiddleware where Self == AuthMiddleware {
    static func auth(_ config: AuthConfig) -> AuthMiddleware {
        AuthMiddleware(config: config)
    }
}

enum AuthMiddlewareError: Error {
    case noCredentialFound
}
