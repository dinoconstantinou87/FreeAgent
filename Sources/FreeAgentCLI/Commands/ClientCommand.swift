import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora
import OpenAPIRuntime
import OpenAPIURLSession

// MARK: - ClientCommand

public protocol ClientCommand: AsyncParsableCommand {
    associatedtype Response: Codable

    var middlewares: [any ClientMiddleware] { get }

    func canRun() throws -> Bool
    func run(client: Client) async throws -> Response?
}

extension ClientCommand {

    // MARK: Public

    public var middlewares: [any ClientMiddleware] {
        []
    }

    public func canRun() throws -> Bool {
        true
    }

    public func run() async throws {
        do {
            guard try canRun() else {
                throw CommandRefusal.declined
            }

            if let result = try await run(client: try await client()) {
                try Noora().json(result)
            }
        } catch {
            if let request = DryRunRequest.from(error) {
                try Noora().json(DryRunOutput(dryRun: request))
                return
            }

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

        let chain: [any ClientMiddleware] = [.apiVersion()] + middlewares + [
            .auth(
                .init(
                    key: config.auth.key,
                    secret: config.auth.secret,
                    environment: credential.environment
                )
            ),
            .apiError(),
        ]

        return Client(
            serverURL: credential.environment.baseURL,
            configuration: .init(dateTranscoder: .freeAgent),
            transport: URLSessionTransport(),
            middlewares: chain
        )
    }
}
