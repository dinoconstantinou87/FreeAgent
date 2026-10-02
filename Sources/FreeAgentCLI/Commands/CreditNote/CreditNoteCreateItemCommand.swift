import ArgumentParser
import Foundation
import FreeAgentAPI

struct CreditNoteCreateItemCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create-item",
        abstract: "Create credit note item"
    )

    @Argument(help: "Credit note ID or URL")
    var creditNote: ResourceID

    @Option(name: .long, help: "Item description")
    var description: String

    @Option(name: .long, help: "Item type")
    var itemType: Components.Schemas.CreditNoteItemPayload.ItemTypePayload?

    @Option(name: .long, help: "Item quantity")
    var quantity: Double?

    @Option(
        name: .long,
        parsing: .unconditional,
        help: "Item price - negative, since only a credit note with a negative total can be sent"
    )
    var price: Double?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.CreditNoteResponse {
        let itemPayload = Components.Schemas.CreditNoteItemPayload(
            description: description,
            itemType: itemType,
            price: price,
            quantity: quantity
        )

        let input = Operations.UpdateCreditNote.Input(
            path: .init(id: creditNote.value),
            body: .json(.init(creditNote: .init(creditNoteItems: [itemPayload])))
        )

        return try await client.updateCreditNote(input)
            .ok.body.json
    }

    func success(for response: Components.Schemas.CreditNoteResponse) -> String {
        guard let item = response.creditNote.creditNoteItems?.last else {
            return "Created item on credit note \(creditNote)"
        }

        return "Created item \(item.url) on credit note \(creditNote)"
    }
}
