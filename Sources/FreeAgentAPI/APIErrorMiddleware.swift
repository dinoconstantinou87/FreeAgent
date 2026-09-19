import Foundation
import HTTPTypes
import OpenAPIRuntime

// MARK: - APIErrorMiddleware

public struct APIErrorMiddleware: ClientMiddleware {

    // MARK: Public

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID _: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let response: HTTPResponse
        let responseBody: HTTPBody?

        do {
            (response, responseBody) = try await next(request, body, baseURL)
        } catch where request.method != .get {
            throw APIError(kind: .unknownOutcome)
        }

        guard response.status.code >= 400 else {
            return (response, responseBody)
        }

        throw APIError(status: Int(response.status.code), messages: await Self.messages(from: responseBody))
    }

    // MARK: Private

    private static func messages(from body: HTTPBody?) async -> [String] {
        guard
            let body,
            let data = try? await Data(collecting: body, upTo: .max)
        else {
            return []
        }

        return APIError.messages(from: data)
    }
}

extension ClientMiddleware where Self == APIErrorMiddleware {
    public static func apiError() -> APIErrorMiddleware {
        APIErrorMiddleware()
    }
}
