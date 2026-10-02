import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora

// MARK: - InvoiceDeleteCommand

struct InvoiceDeleteCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete an invoice",
        discussion: "Only a draft invoice can be deleted."
    )

    @Argument(help: "Invoice ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    var confirmation: String {
        "Delete invoice \(id)?"
    }

    func perform(client: Client) async throws -> EmptyResponse {
        let input = Operations.DeleteInvoice.Input(
            path: .init(id: id.value)
        )

        do {
            _ = try await client.deleteInvoice(input).ok
        } catch where APIError.from(error)?.status == 409 {
            guard let invoice = try? await client.showInvoice(.init(path: .init(id: id.value))).ok.body.json.invoice else {
                throw error
            }

            if
                let paidValue = invoice.paidValue,
                let paid = Decimal(string: paidValue, locale: Locale(identifier: "en_US_POSIX")),
                paid != 0
            {
                throw InvoiceDeleteCommandError.hasPayments(id: id.value)
            }

            switch invoice.status {
            case "Draft", nil:
                throw error
            case "Written-off", "Part written-off":
                throw InvoiceDeleteCommandError.writtenOff(id: id.value)
            default:
                throw InvoiceDeleteCommandError.notDraft(id: id.value)
            }
        }

        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Deleted invoice \(id)"
    }
}

// MARK: - InvoiceDeleteCommandError

enum InvoiceDeleteCommandError: CommandError {
    case hasPayments(id: String)
    case writtenOff(id: String)
    case notDraft(id: String)

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .hasPayments(let id):
            "Invoice \(id) has payments, and only a draft can be deleted"
        case .writtenOff(let id):
            "Invoice \(id) is written off, and only a draft can be deleted"
        case .notDraft(let id):
            "Invoice \(id) is not a draft, and only a draft can be deleted"
        }
    }

    var exitCode: ExitCode {
        APIError.Kind.rejected.exitCode
    }

    var takeaways: [TerminalText] {
        switch self {
        case .hasPayments(let id):
            [
                "Delete the bank transaction explanations that pay it",
                "Then run \(.command("freeagent invoice mark-draft \(id)")) and try again",
            ]

        case .writtenOff(let id):
            [
                "Run \(.command("freeagent invoice mark-sent \(id)")) to re-open it",
                "Then run \(.command("freeagent invoice mark-draft \(id)")) and try again",
            ]

        case .notDraft(let id):
            ["Run \(.command("freeagent invoice mark-draft \(id)")) first"]
        }
    }
}
