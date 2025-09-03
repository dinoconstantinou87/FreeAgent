import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct InvoiceMarkSentCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-sent",
        abstract: "Mark invoice as sent"
    )
    
    @Argument(help: "Invoice ID")
    var id: String
    
    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIObjectContainer? {
        let input = Operations.MarkInvoiceAsSent.Input(
            path: .init(id: id)
        )
        
        return try await client.markInvoiceAsSent(input)
            .ok.body.json.additionalProperties
    }
}