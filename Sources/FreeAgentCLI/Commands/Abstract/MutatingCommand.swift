import FreeAgentAPI
import Noora
import OpenAPIRuntime

// MARK: - MutatingCommand

protocol MutatingCommand: ClientCommand {
    associatedtype Response

    var dryRun: Bool { get }
    var json: Bool { get }

    func perform(client: Client) async throws -> Response
    func success(for response: Response) -> String
}

extension MutatingCommand {
    var middlewares: [any ClientMiddleware] {
        dryRun ? [.dryRun()] : []
    }

    func run(client: Client) async throws -> Response? {
        let response = try await perform(client: client)

        if json {
            return response
        }

        Noora().success(.alert(TerminalText(stringLiteral: success(for: response))))
        return nil
    }
}

extension MutatingCommand where Response == EmptyResponse {
    var json: Bool {
        false
    }
}
