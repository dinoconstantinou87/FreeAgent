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
        
        let response = try await client.markInvoiceAsDraft(input)
        
        switch response {
        case .ok(let okResponse):
            return try okResponse.body.json.additionalProperties
        default:
            return nil
        }
    }
}