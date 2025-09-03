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

        _ = try await client.deleteInvoice(input).ok
        return nil
    }
}
