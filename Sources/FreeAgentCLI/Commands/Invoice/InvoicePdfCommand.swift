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
        
        let response = try await client.showInvoiceAsPdf(input)
        
        switch response {
        case .ok(let okResponse):
            return try okResponse.body.json.additionalProperties
        default:
            return nil
        }
    }
}