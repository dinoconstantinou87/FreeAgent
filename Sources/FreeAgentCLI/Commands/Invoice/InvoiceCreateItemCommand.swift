import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct InvoiceCreateItemCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "create-item",
        abstract: "Create invoice item"
    )
    
    @Argument(help: "Invoice ID")
    var invoice: String
    
    @Option(name: .long, help: "Item description")
    var description: String
    
    @Option(name: .long, help: "Item type")
    var itemType: Operations.CreateInvoiceItem.Input.Body.JsonPayload.InvoiceItemPayload.ItemTypePayload?
    
    @Option(name: .long, help: "Item quantity")
    var quantity: Double?
    
    @Option(name: .long, help: "Item price")
    var price: Double?
    
    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIObjectContainer? {
        let invoiceItemPayload = Operations.CreateInvoiceItem.Input.Body.JsonPayload.InvoiceItemPayload(
            description: description,
            itemType: itemType,
            price: price,
            quantity: quantity
        )
        
        let input = Operations.CreateInvoiceItem.Input(
            body: .json(.init(invoice: invoice, invoiceItem: invoiceItemPayload))
        )
        
        return try await client.createInvoiceItem(input)
            .created.body.json.additionalProperties
    }
}