import ArgumentParser
import Foundation
import FreeAgentAPI
import OpenAPIRuntime

struct InvoiceUpdateItemCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "update-item",
        abstract: "Update an invoice item"
    )

    @Argument(help: "Invoice item ID")
    var id: String

    @Option(name: .long, help: "Item description")
    var description: String?

    @Option(name: .long, help: "Item type")
    var itemType: Components.Schemas.InvoiceItemPayload.ItemTypePayload?

    @Option(name: .long, help: "Item quantity")
    var quantity: Double?

    @Option(name: .long, help: "Item price")
    var price: Double?

    func run(client: Client) async throws -> OpenAPIObjectContainer? {
        let itemPayload = Components.Schemas.InvoiceItemPayload(
            description: description,
            itemType: itemType,
            price: price,
            quantity: quantity
        )

        let input = Operations.UpdateInvoiceItem.Input(
            path: .init(id: id),
            body: .json(.init(invoiceItem: itemPayload))
        )

        return try await client.updateInvoiceItem(input)
            .ok.body.json.additionalProperties
    }
}
