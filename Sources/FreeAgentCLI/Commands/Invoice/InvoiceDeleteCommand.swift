import ArgumentParser
import Foundation
import FreeAgentAPI
import OpenAPIRuntime

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

    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIValueContainer? {
        let input = Operations.DeleteInvoice.Input(
            path: .init(id: id)
        )

        _ = try await client.deleteInvoice(input).ok
        return nil
    }
}
