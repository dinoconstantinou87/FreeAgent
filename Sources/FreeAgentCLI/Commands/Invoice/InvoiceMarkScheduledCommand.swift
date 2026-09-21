import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceMarkScheduledCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-scheduled",
        abstract: "Mark invoice as scheduled"
    )

    @Argument(help: "Invoice ID")
    var id: String

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    func run(client: Client) async throws -> Components.Schemas.InvoiceResponse? {
        let input = Operations.MarkInvoiceAsScheduled.Input(
            path: .init(id: id)
        )

        return try await client.markInvoiceAsScheduled(input)
            .ok.body.json
    }
}
