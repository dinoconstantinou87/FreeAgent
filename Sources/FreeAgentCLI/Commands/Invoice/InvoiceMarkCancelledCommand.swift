import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceMarkCancelledCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-cancelled",
        abstract: "Mark invoice as cancelled"
    )

    @Argument(help: "Invoice ID")
    var id: String

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    func run(client: Client) async throws -> Components.Schemas.InvoiceResponse? {
        let input = Operations.MarkInvoiceAsCancelled.Input(
            path: .init(id: id)
        )

        return try await client.markInvoiceAsCancelled(input)
            .ok.body.json
    }
}
