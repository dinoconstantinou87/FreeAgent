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

    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIValueContainer? {
        let input = Operations.DeleteInvoice.Input(
            path: .init(id: id)
        )

        let response = try await client.deleteInvoice(input)
        let _ = try response.ok

        return nil
    }
}
