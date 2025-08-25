import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct InvoiceListCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List invoices"
    )
    
    @Option(name: .long, help: "Filter by view")
    var view: CustomInvoiceView?
    
    @Option(name: .long, help: "Filter invoices by contact URL")
    var contact: String?
    
    @Option(name: .long, help: "Filter invoices by project URL")
    var project: String?
    
    @Option(name: .long, help: "Include invoice items nested within each invoice")
    var nestedInvoiceItems: Bool?
    
    @Option(name: .long, help: "Filter invoices by currency code")
    var currency: String?
    
    @Option(name: .long, help: "Show invoices updated after this timestamp")
    var updatedSince: String?
    
    @Option(name: .long, help: "Sort order")
    var sort: Operations.ListInvoices.Input.Query.SortPayload?
    
    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIObjectContainer? {
        let input = Operations.ListInvoices.Input(
            query: .init(
                nestedInvoiceItems: nestedInvoiceItems,
                contact: contact,
                project: project,
                currency: currency,
                view: view,
                updatedSince: updatedSince,
                sort: sort
            )
        )
        
        let response = try await client.listInvoices(input)
        
        switch response {
        case .ok(let okResponse):
            return try okResponse.body.json.additionalProperties
        default:
            return nil
        }
    }
}