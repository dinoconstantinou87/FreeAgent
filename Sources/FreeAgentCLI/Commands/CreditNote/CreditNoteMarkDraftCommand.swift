import ArgumentParser
import Foundation
import FreeAgentAPI

struct CreditNoteMarkDraftCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-draft",
        abstract: "Mark credit note as draft"
    )

    @Argument(help: "Credit note ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.CreditNoteResponse {
        let input = Operations.MarkCreditNoteAsDraft.Input(
            path: .init(id: id.value)
        )

        return try await client.markCreditNoteAsDraft(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.CreditNoteResponse) -> String {
        "Marked credit note \(id) as draft"
    }
}
