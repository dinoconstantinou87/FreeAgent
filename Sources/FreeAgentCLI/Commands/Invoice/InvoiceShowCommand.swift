import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceShowCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show invoice details"
    )

    @Argument(help: "Invoice ID")
    var id: String

    func run(client: Client) async throws -> Components.Schemas.InvoiceResponse? {
        let input = Operations.ShowInvoice.Input(
            path: .init(id: id)
        )

        return try await client.showInvoice(input)
            .ok.body.json
    }
}
