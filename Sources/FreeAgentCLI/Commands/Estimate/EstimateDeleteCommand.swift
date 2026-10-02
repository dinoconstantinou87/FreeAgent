import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora

// MARK: - EstimateDeleteCommand

struct EstimateDeleteCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a draft estimate"
    )

    @Argument(help: "Estimate ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    var confirmation: String {
        "Delete estimate \(id)?"
    }

    func perform(client: Client) async throws -> EmptyResponse {
        let input = Operations.DeleteEstimate.Input(
            path: .init(id: id.value)
        )

        do {
            _ = try await client.deleteEstimate(input).ok
        } catch where APIError.from(error)?.status == 409 {
            throw EstimateDeleteCommandError.notDraft(id: id.value)
        }

        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Deleted estimate \(id)"
    }
}

// MARK: - EstimateDeleteCommandError

enum EstimateDeleteCommandError: CommandError {
    case notDraft(id: String)

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .notDraft(let id):
            "Estimate \(id) is not a draft, and only a draft can be deleted"
        }
    }

    var exitCode: ExitCode {
        APIError.Kind.rejected.exitCode
    }

    var takeaways: [TerminalText] {
        switch self {
        case .notDraft(let id):
            ["Run \(.command("freeagent estimate mark-draft \(id)")) first"]
        }
    }
}
