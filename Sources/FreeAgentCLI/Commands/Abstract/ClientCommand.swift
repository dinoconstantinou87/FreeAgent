import ArgumentParser
import Configuration
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
                throw ClientCommandError.cancelled
            }

            if let result = try await run(client: try await client()) {
                try Noora().json(result)
            }
        } catch {
            if let request = DryRunRequest.from(error) {
                try Noora().json(DryRunOutput(dryRun: request))
                return
            }

            let failure = error.commandError
            Noora().error(failure.alert)
            throw failure.exitCode
        }
    }

    // MARK: Private

    private func client() async throws -> Client {
        guard let credential = try AuthStorage().get() else {
            throw APIError(kind: .unauthenticated)
        }

        let auth = try await AuthConfig(config: Config.reader(environment: credential.environment).scoped(to: "auth"))

        let chain: [any ClientMiddleware] = [.apiVersion()] + middlewares + [
            .auth(auth),
            .apiError(),
            .retry(willRetry: { delay in
                Noora.standardError().info(.alert("Rate limited - retrying in \(delay.components.seconds)s"))
            }),
        ]

        return Client(
            serverURL: auth.environment.baseURL,
            configuration: .init(dateTranscoder: .freeAgent),
            transport: URLSessionTransport(),
            middlewares: chain
        )
    }
}

// MARK: - ClientCommandError

enum ClientCommandError: CommandError {
    case cancelled

    var errorDescription: String? {
        switch self {
        case .cancelled:
            "Cancelled, nothing was changed"
        }
    }

    var exitCode: ExitCode {
        .failure
    }
}
