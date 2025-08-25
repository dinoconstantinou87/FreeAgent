import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct InvoiceListRecurringCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List recurring invoices"
    )
    
    @Option(name: .long, help: "Filter by view")
    var view: Operations.ListAllRecurringInvoices.Input.Query.ViewPayload?
    
    @Option(name: .long, help: "Filter by contact URL")
    var contact: String?
    
    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIObjectContainer? {
        let input = Operations.ListAllRecurringInvoices.Input(
            query: .init(
                view: view,
                contact: contact
            )
        )
        
        let response = try await client.listAllRecurringInvoices(input)
        
        switch response {
        case .ok(let okResponse):
            return try okResponse.body.json.additionalProperties
        default:
            return nil
        }
    }
}