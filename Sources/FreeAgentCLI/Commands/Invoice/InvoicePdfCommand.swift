import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct InvoicePdfCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "pdf",
        abstract: "Get invoice as PDF"
    )
    
    @Argument(help: "Invoice ID")
    var id: String
    
    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIObjectContainer? {
        let input = Operations.ShowInvoiceAsPdf.Input(
            path: .init(id: id)
        )
        
        return try await client.showInvoiceAsPdf(input)
            .ok.body.json.additionalProperties
    }
}