import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceDeleteCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete an invoice"
    )

    @Argument(help: "Invoice ID")
    var id: String

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    var confirmation: String {
        "Delete invoice \(id)?"
    }

    func perform(client: Client) async throws -> EmptyResponse {
        let input = Operations.DeleteInvoice.Input(
            path: .init(id: id)
        )

        _ = try await client.deleteInvoice(input).ok
        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Deleted invoice \(id)"
    }
}
