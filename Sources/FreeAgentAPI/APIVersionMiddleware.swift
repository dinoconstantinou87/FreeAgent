import Foundation
import HTTPTypes
import OpenAPIRuntime

// MARK: - APIVersionMiddleware

public struct APIVersionMiddleware: ClientMiddleware {

    // MARK: Public

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID _: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        request.headerFields[Self.header] = version

        return try await next(request, body, baseURL)
    }

    // MARK: Internal

    let version: String

    // MARK: Private

    private static let header = HTTPField.Name("X-Api-Version")!
}

extension ClientMiddleware where Self == APIVersionMiddleware {
    public static func apiVersion(_ version: String = FreeAgentAPI.apiVersion) -> APIVersionMiddleware {
        APIVersionMiddleware(version: version)
    }
}
