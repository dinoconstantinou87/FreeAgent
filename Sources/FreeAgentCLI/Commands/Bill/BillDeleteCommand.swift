import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora

// MARK: - BillDeleteCommand

struct BillDeleteCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a bill"
    )

    @Argument(help: "Bill ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    var confirmation: String {
        "Delete bill \(id)?"
    }

    func perform(client: Client) async throws -> EmptyResponse {
        let input = Operations.DeleteBill.Input(
            path: .init(id: id.value)
        )

        do {
            _ = try await client.deleteBill(input).ok
        } catch where APIError.from(error)?.status == 409 {
            guard
                let paidValue = try? await client.showBill(.init(path: .init(id: id.value))).ok.body.json.bill.paidValue,
                let paid = Decimal(string: paidValue, locale: Locale(identifier: "en_US_POSIX")),
                paid != 0
            else {
                throw error
            }

            throw BillDeleteCommandError.hasPayments(id: id.value)
        }

        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Deleted bill \(id)"
    }
}

// MARK: - BillDeleteCommandError

enum BillDeleteCommandError: CommandError {
    case hasPayments(id: String)

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .hasPayments(let id):
            "Bill \(id) has payments, and a bill with payments cannot be deleted"
        }
    }

    var exitCode: ExitCode {
        APIError.Kind.rejected.exitCode
    }

    var takeaways: [TerminalText] {
        switch self {
        case .hasPayments:
            ["Delete the bank transaction explanations that pay it, then try again"]
        }
    }
}
