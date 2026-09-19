import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora
import OpenAPIRuntime
import OpenAPIURLSession

// MARK: - ClientCommand

public protocol ClientCommand: AsyncParsableCommand {
    associatedtype Response: Codable

    func run(client: Client) async throws -> Response?
}

extension ClientCommand {

    // MARK: Public

    public func run() async throws {
        do {
            if let result = try await run(client: try await client()) {
                try Noora().json(result)
            }
        } catch {
            let failure = CommandFailure(error)
            Noora().error(failure.alert)
            throw failure.exitCode
        }
    }

    // MARK: Private

    private func client() async throws -> Client {
        guard let credential = try AuthStorage().get() else {
            throw APIError(kind: .unauthenticated)
        }

        let config = try await Config.load()

        return Client(
            serverURL: credential.environment.baseURL,
            configuration: .init(dateTranscoder: .freeAgent),
            transport: URLSessionTransport(),
            middlewares: [
                .auth(
                    .init(
                        key: config.auth.key,
                        secret: config.auth.secret,
                        environment: credential.environment
                    )
                ),
                .apiVersion(),
                .apiError(),
            ]
        )
    }
}
