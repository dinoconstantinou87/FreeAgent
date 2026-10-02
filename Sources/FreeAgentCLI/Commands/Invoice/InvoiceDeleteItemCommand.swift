import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceDeleteItemCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete-item",
        abstract: "Delete an invoice item"
    )

    @Argument(help: "Invoice item ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    var confirmation: String {
        "Delete invoice item \(id)?"
    }

    func perform(client: Client) async throws -> EmptyResponse {
        let input = Operations.DeleteInvoiceItem.Input(
            path: .init(id: id.value)
        )

        _ = try await client.deleteInvoiceItem(input).ok
        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Deleted invoice item \(id)"
    }
}
