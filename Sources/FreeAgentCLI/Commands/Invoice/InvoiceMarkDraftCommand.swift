import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceMarkDraftCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-draft",
        abstract: "Mark invoice as draft"
    )

    @Argument(help: "Invoice ID")
    var id: String

    func run(client: Client) async throws -> Components.Schemas.InvoiceResponse? {
        let input = Operations.MarkInvoiceAsDraft.Input(
            path: .init(id: id)
        )

        return try await client.markInvoiceAsDraft(input)
            .ok.body.json
    }
}
