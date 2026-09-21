import Foundation
import HTTPTypes
import OpenAPIRuntime

// MARK: - DryRunMiddleware

public struct DryRunMiddleware: ClientMiddleware {
    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID _: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        guard request.method != .get else {
            return try await next(request, body, baseURL)
        }

        throw try await DryRunRequest(request, body: body, baseURL: baseURL)
    }
}

extension ClientMiddleware where Self == DryRunMiddleware {
    public static func dryRun() -> DryRunMiddleware {
        DryRunMiddleware()
    }
}
