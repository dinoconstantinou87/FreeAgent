import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora

// MARK: - CreditNoteDeleteCommand

struct CreditNoteDeleteCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a draft credit note"
    )

    @Argument(help: "Credit note ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    var confirmation: String {
        "Delete credit note \(id)?"
    }

    func perform(client: Client) async throws -> EmptyResponse {
        let input = Operations.DeleteCreditNote.Input(
            path: .init(id: id.value)
        )

        do {
            _ = try await client.deleteCreditNote(input).ok
        } catch where APIError.from(error)?.status == 409 {
            throw CreditNoteDeleteCommandError.notDraft(id: id.value)
        }

        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Deleted credit note \(id)"
    }
}

// MARK: - CreditNoteDeleteCommandError

enum CreditNoteDeleteCommandError: CommandError {
    case notDraft(id: String)

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .notDraft(let id):
            "Credit note \(id) is not a draft, and only a draft can be deleted"
        }
    }

    var exitCode: ExitCode {
        APIError.Kind.rejected.exitCode
    }

    var takeaways: [TerminalText] {
        switch self {
        case .notDraft(let id):
            ["Run \(.command("freeagent credit-note mark-draft \(id)")) first"]
        }
    }
}
