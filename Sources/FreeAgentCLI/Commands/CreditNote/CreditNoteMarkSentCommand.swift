import ArgumentParser
import Foundation
import FreeAgentAPI

struct CreditNoteMarkSentCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-sent",
        abstract: "Mark credit note as sent"
    )

    @Argument(help: "Credit note ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.CreditNoteResponse {
        let input = Operations.MarkCreditNoteAsSent.Input(
            path: .init(id: id.value)
        )

        return try await client.markCreditNoteAsSent(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.CreditNoteResponse) -> String {
        "Marked credit note \(id) as sent"
    }
}
