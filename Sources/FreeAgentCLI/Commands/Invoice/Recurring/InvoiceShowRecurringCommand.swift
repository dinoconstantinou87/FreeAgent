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
        
        return try await client.showRecurringInvoice(input)
            .ok.body.json.additionalProperties
    }
}