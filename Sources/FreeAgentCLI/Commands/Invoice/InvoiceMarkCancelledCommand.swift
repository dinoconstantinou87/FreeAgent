import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct InvoiceMarkCancelledCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-cancelled",
        abstract: "Mark invoice as cancelled"
    )
    
    @Argument(help: "Invoice ID")
    var id: String
    
    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIObjectContainer? {
        let input = Operations.MarkInvoiceAsCancelled.Input(
            path: .init(id: id)
        )
        
        return try await client.markInvoiceAsCancelled(input)
            .ok.body.json.additionalProperties
    }
}