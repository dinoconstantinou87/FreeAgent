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

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.InvoiceResponse {
        let input = Operations.MarkInvoiceAsScheduled.Input(
            path: .init(id: id)
        )

        return try await client.markInvoiceAsScheduled(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.InvoiceResponse) -> String {
        "Marked invoice \(id) as scheduled"
    }
}
