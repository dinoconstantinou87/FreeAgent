import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct InvoiceMarkDraftCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-draft",
        abstract: "Mark invoice as draft"
    )
    
    @Argument(help: "Invoice ID")
    var id: String
    
    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIObjectContainer? {
        let input = Operations.MarkInvoiceAsDraft.Input(
            path: .init(id: id)
        )
        
        return try await client.markInvoiceAsDraft(input)
            .ok.body.json.additionalProperties
    }
}