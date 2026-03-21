import Foundation
import HTTPTypes
import OpenAPIRuntime

// MARK: - AuthMiddleware

public struct AuthMiddleware: ClientMiddleware {

    // MARK: Public

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID _: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let credential = try await credential()
        var request = request
        request.headerFields[.authorization] = "Bearer \(credential.token)"

        return try await next(request, body, baseURL)
    }

    // MARK: Internal

    let config: AuthConfig
    let storage: any AuthStorageInterface

    // MARK: Private

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

extension ClientMiddleware where Self == AuthMiddleware {
    public static func auth(_ config: AuthConfig, storage: any AuthStorageInterface = AuthStorage()) -> AuthMiddleware {
        AuthMiddleware(config: config, storage: storage)
    }
}

// MARK: - AuthMiddlewareError

enum AuthMiddlewareError: Error {
    case noCredentialFound
}
