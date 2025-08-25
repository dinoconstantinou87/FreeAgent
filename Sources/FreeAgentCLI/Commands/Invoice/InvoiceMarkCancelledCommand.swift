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
        
        let response = try await client.markInvoiceAsCancelled(input)
        
        switch response {
        case .ok(let okResponse):
            return try okResponse.body.json.additionalProperties
        default:
            return nil
        }
    }
}