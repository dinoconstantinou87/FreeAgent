import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceUpdateCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update an existing invoice"
    )

    @Argument(help: "Invoice ID")
    var id: String

    @Option(name: .long, help: "Notes for the invoice")
    var notes: String?

    func run(client: Client) async throws -> Components.Schemas.InvoiceResponse? {
        let invoicePayload = Components.Schemas.InvoiceUpdatePayload(
            notes: notes
        )

        let input = Operations.UpdateInvoice.Input(
            path: .init(id: id),
            body: .json(.init(invoice: invoicePayload))
        )

        return try await client.updateInvoice(input)
            .ok.body.json
    }
}
