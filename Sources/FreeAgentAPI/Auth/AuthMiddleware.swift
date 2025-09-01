import Foundation
import OpenAPIRuntime
import HTTPTypes

public struct AuthMiddleware: ClientMiddleware {
    let token: String

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        request.headerFields[.authorization] = "Bearer \(token)"

        return try await next(request, body, baseURL)
    }
}

public extension ClientMiddleware where Self == AuthMiddleware {
    static func auth(_ token: String) -> AuthMiddleware {
        AuthMiddleware(token: token)
    }
}
