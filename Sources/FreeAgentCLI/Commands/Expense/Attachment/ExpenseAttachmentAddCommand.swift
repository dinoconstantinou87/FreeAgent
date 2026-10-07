import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora

// MARK: - ExpenseAttachmentAddCommand

struct ExpenseAttachmentAddCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add an attachment to an expense",
        discussion: "An expense holds one attachment of up to 5MB. Remove the one it has before adding another."
    )

    @Argument(help: "Expense ID or URL")
    var id: ResourceID

    @Option(name: .long, help: "Path to the file to attach (pdf, png, jpg, jpeg or gif)")
    var file: String

    @Option(name: .long, help: "Description of the attached file")
    var description: String?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.ExpenseResponse {
        let attachment = try AttachmentFile(path: file)

        let expense = try await client.getASingleExpense(.init(path: .init(id: id.value))).ok.body.json.expense

        if let existing = expense.attachment {
            throw ExpenseAttachmentAddCommandError.alreadyAttached(id: id, fileName: existing.fileName)
        }

        let input = Operations.UpdateExpense.Input(
            path: .init(id: id.value),
            body: .json(.init(expense: .init(attachment: .init(
                data: attachment.data,
                fileName: attachment.fileName,
                contentType: attachment.contentType,
                description: description
            ))))
        )

        return try await client.updateExpense(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.ExpenseResponse) -> String {
        "Added the attachment to expense \(id)"
    }
}

// MARK: - ExpenseAttachmentAddCommandError

enum ExpenseAttachmentAddCommandError: CommandError {
    case alreadyAttached(id: ResourceID, fileName: String?)

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .alreadyAttached(let id, let fileName?):
            "Expense \(id) already has an attachment, \(fileName)"
        case .alreadyAttached(let id, nil):
            "Expense \(id) already has an attachment"
        }
    }

    var exitCode: ExitCode {
        APIError.Kind.rejected.exitCode
    }

    var takeaways: [TerminalText] {
        switch self {
        case .alreadyAttached(let id, _):
            ["Run \(.command("freeagent expense attachment remove \(id)")) first to replace it"]
        }
    }
}
