import FreeAgentAPI
import OpenAPIRuntime

// MARK: - MutatingCommand

protocol MutatingCommand: ClientCommand {
    var dryRun: Bool { get }
}

extension MutatingCommand {
    var middlewares: [any ClientMiddleware] {
        dryRun ? [.dryRun()] : []
    }
}
