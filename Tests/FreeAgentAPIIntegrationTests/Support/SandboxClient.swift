import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

@testable import FreeAgentAPI

// MARK: - SandboxClient

enum SandboxClient {

    static var token: String? {
        if let token = ProcessInfo.processInfo.environment["FREEAGENT_ACCESS_TOKEN"], !token.isEmpty {
            return token
        }

        guard
            let credential = try? AuthStorage().get(),
            credential.environment == .sandbox
        else {
            return nil
        }

        return credential.token
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
                .bearerToken(token),
                .apiVersion(),
                .apiError(),
                .retry(),
            ]
        )
    }

}
