import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceMarkScheduledCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-scheduled",
        abstract: "Mark invoice as scheduled"
    )

    @Argument(help: "Invoice ID")
    var id: String

    func run(client: Client) async throws -> Components.Schemas.InvoiceResponse? {
        let input = Operations.MarkInvoiceAsScheduled.Input(
            path: .init(id: id)
        )

        return try await client.markInvoiceAsScheduled(input)
            .ok.body.json
    }
}
