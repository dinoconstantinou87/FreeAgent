import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceCreateItemCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create-item",
        abstract: "Create invoice item"
    )

    @Argument(help: "Invoice ID or URL")
    var invoice: ResourceID

    @Option(name: .long, help: "Item description")
    var description: String

    @Option(name: .long, help: "Item type")
    var itemType: Components.Schemas.InvoiceItemPayload.ItemTypePayload?

    @Option(name: .long, help: "Item quantity")
    var quantity: Double?

    @Option(name: .long, parsing: .unconditional, help: "Item price")
    var price: Double?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.InvoiceItemResponse {
        let invoiceItemPayload = Components.Schemas.InvoiceItemPayload(
            description: description,
            itemType: itemType,
            price: price,
            quantity: quantity
        )

        let input = Operations.CreateInvoiceItem.Input(
            body: .json(.init(invoice: invoice.value, invoiceItem: invoiceItemPayload))
        )

        return try await client.createInvoiceItem(input)
            .created.body.json
    }

    func success(for response: Components.Schemas.InvoiceItemResponse) -> String {
        "Created item \(response.invoiceItem.url) on invoice \(invoice)"
    }
}
