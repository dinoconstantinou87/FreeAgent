import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora

// MARK: - ExpenseDeleteCommand

struct ExpenseDeleteCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete an expense"
    )

    @Argument(help: "Expense ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    var confirmation: String {
        "Delete expense \(id)?"
    }

    func perform(client: Client) async throws -> EmptyResponse {
        let input = Operations.DeleteExpense.Input(
            path: .init(id: id.value)
        )

        do {
            _ = try await client.deleteExpense(input).ok
        } catch where APIError.from(error)?.status == 409 {
            guard
                let invoice = try? await client.getASingleExpense(.init(path: .init(id: id.value))).ok.body.json.expense
                    .rebilledOnInvoice
            else {
                throw error
            }

            throw ExpenseDeleteCommandError.rebilled(id: id.value, invoice: ResourceID(invoice).value)
        }

        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Deleted expense \(id)"
    }
}

// MARK: - ExpenseDeleteCommandError

enum ExpenseDeleteCommandError: CommandError {
    case rebilled(id: String, invoice: String)

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .rebilled(let id, let invoice):
            "Expense \(id) is rebilled on invoice \(invoice), and a rebilled expense cannot be deleted"
        }
    }

    var exitCode: ExitCode {
        APIError.Kind.rejected.exitCode
    }

    var takeaways: [TerminalText] {
        switch self {
        case .rebilled(_, let invoice):
            [
                "Remove the expense's line from invoice \(invoice) in FreeAgent",
                "Or run \(.command("freeagent invoice delete \(invoice)")), which unbills every expense on it",
            ]
        }
    }
}
