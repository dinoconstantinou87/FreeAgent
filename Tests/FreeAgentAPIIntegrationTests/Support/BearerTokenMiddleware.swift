import Foundation
import HTTPTypes
import OpenAPIRuntime

// MARK: - BearerTokenMiddleware

struct BearerTokenMiddleware: ClientMiddleware {
    let token: String

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID _: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        request.headerFields[.authorization] = "Bearer \(token)"
        return try await next(request, body, baseURL)
    }
}

extension ClientMiddleware where Self == BearerTokenMiddleware {
    static func bearerToken(_ token: String) -> BearerTokenMiddleware {
        BearerTokenMiddleware(token: token)
    }
}
