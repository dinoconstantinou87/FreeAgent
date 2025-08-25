import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct InvoiceDeleteCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete an invoice"
    )
    
    @Argument(help: "Invoice ID")
    var id: String
    
    @Flag(help: "Confirm deletion without prompting")
    var force: Bool = false
    
    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIObjectContainer? {
        if !force {
            print("Are you sure you want to delete invoice \(id)? This action cannot be undone.")
            print("Use --force to skip this confirmation.")
            return nil
        }
        
        let input = Operations.DeleteInvoice.Input(
            path: .init(id: id),
            body: .multipartForm(.init([]))
        )
        
        let response = try await client.deleteInvoice(input)
        let okResponse = try response.ok
        return try okResponse.body.json.additionalProperties
    }
}