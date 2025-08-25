import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct InvoiceShowCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show invoice details"
    )
    
    @Argument(help: "Invoice ID")
    var id: String
    
    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIObjectContainer? {
        let input = Operations.ShowInvoice.Input(
            path: .init(id: id)
        )
        
        let response = try await client.showInvoice(input)
        let okResponse = try response.ok
        return try okResponse.body.json.additionalProperties
    }
}