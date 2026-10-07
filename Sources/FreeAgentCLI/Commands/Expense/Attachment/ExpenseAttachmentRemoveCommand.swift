import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora

// MARK: - ExpenseAttachmentRemoveCommand

struct ExpenseAttachmentRemoveCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "remove",
        abstract: "Remove the attachment from an expense",
        discussion: "FreeAgent deletes the attached file."
    )

    @Argument(help: "Expense ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    var confirmation: String {
        "Remove the attachment from expense \(id)?"
    }

    func perform(client: Client) async throws -> Components.Schemas.ExpenseResponse {
        let expense = try await client.getASingleExpense(.init(path: .init(id: id.value))).ok.body.json.expense

        guard expense.attachment != nil else {
            throw ExpenseAttachmentRemoveCommandError.noAttachment(id: id)
        }

        let input = Operations.UpdateExpense.Input(
            path: .init(id: id.value),
            body: .json(.init(expense: .init(attachment: .init(_destroy: 1))))
        )

        return try await client.updateExpense(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.ExpenseResponse) -> String {
        "Removed the attachment from expense \(id)"
    }
}

// MARK: - ExpenseAttachmentRemoveCommandError

enum ExpenseAttachmentRemoveCommandError: CommandError {
    case noAttachment(id: ResourceID)

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .noAttachment(let id):
            "Expense \(id) has no attachment"
        }
    }

    var exitCode: ExitCode {
        APIError.Kind.notFound.exitCode
    }
}
