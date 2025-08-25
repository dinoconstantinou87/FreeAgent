import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct InvoiceShowRecurringCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show recurring invoice details"
    )
    
    @Argument(help: "Recurring invoice ID")
    var id: String
    
    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIObjectContainer? {
        let input = Operations.ShowRecurringInvoice.Input(
            path: .init(id: id)
        )
        
        let response = try await client.showRecurringInvoice(input)
        
        switch response {
        case .ok(let okResponse):
            return try okResponse.body.json.additionalProperties
        default:
            return nil
        }
    }
}