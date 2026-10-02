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
        var request = request
        request.headerFields[.authorization] = "Bearer \(try await client.token())"

        return try await next(request, body, baseURL)
    }

    // MARK: Internal

    let client: AuthClient

}

extension ClientMiddleware where Self == AuthMiddleware {
    public static func auth(_ config: AuthConfig, storage: any AuthStorageInterface = AuthStorage()) -> AuthMiddleware {
        AuthMiddleware(client: AuthClient(config: config, storage: storage))
    }
}
