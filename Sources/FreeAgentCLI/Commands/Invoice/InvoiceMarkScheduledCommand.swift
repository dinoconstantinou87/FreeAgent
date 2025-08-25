import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct InvoiceMarkScheduledCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-scheduled",
        abstract: "Mark invoice as scheduled"
    )
    
    @Argument(help: "Invoice ID")
    var id: String
    
    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIObjectContainer? {
        let input = Operations.MarkInvoiceAsScheduled.Input(
            path: .init(id: id)
        )
        
        let response = try await client.markInvoiceAsScheduled(input)
        let okResponse = try response.ok
        return try okResponse.body.json.additionalProperties
    }
}