import Configuration
import Foundation
import HTTPTypes
import OpenAPIRuntime
import OpenAPIURLSession

@testable import FreeAgentAPI

// MARK: - SandboxClient

enum SandboxClient {

    static let reader = ConfigReader(providers: [
        EnvironmentVariablesProvider().prefixKeys(with: "freeagent")
    ])

    static var token: String? {
        guard let token = reader.string(forKey: "token", isSecret: true), !token.isEmpty else {
            return nil
        }

        return token
    }

    static func makeClient() -> Client? {
        guard let token else {
            return nil
        }

        return Client(
            serverURL: Environment.sandbox.baseURL,
            configuration: .init(dateTranscoder: .freeAgent),
            transport: URLSessionTransport(),
            middlewares: [
                BearerTokenMiddleware(token: token),
                APIVersionMiddleware(version: apiVersion),
                APIErrorMiddleware(),
            ]
        )
    }

}

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
