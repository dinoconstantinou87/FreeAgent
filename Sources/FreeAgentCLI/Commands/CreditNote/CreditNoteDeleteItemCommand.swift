import ArgumentParser
import Foundation
import FreeAgentAPI

struct CreditNoteDeleteItemCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete-item",
        abstract: "Delete a credit note item"
    )

    @Argument(help: "Credit note ID or URL")
    var creditNote: ResourceID

    @Argument(help: "Credit note item ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    var confirmation: String {
        "Delete credit note item \(id)?"
    }

    func perform(client: Client) async throws -> Components.Schemas.CreditNoteResponse {
        let itemPayload = Components.Schemas.CreditNoteItemPayload(
            id: id.value,
            _destroy: 1
        )

        let input = Operations.UpdateCreditNote.Input(
            path: .init(id: creditNote.value),
            body: .json(.init(creditNote: .init(creditNoteItems: [itemPayload])))
        )

        return try await client.updateCreditNote(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.CreditNoteResponse) -> String {
        "Deleted credit note item \(id)"
    }
}
