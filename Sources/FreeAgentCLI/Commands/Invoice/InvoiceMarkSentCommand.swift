import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceMarkSentCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-sent",
        abstract: "Mark invoice as sent"
    )

    @Argument(help: "Invoice ID")
    var id: String

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    func run(client: Client) async throws -> Components.Schemas.InvoiceResponse? {
        let input = Operations.MarkInvoiceAsSent.Input(
            path: .init(id: id)
        )

        return try await client.markInvoiceAsSent(input)
            .ok.body.json
    }
}
