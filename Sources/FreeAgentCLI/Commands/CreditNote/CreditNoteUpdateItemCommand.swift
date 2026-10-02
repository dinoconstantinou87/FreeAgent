import ArgumentParser
import Foundation
import FreeAgentAPI

struct CreditNoteUpdateItemCommand: MutatingCommand {

    // MARK: Internal

    static let configuration = CommandConfiguration(
        commandName: "update-item",
        abstract: "Update a credit note item"
    )

    @Argument(help: "Credit note ID or URL")
    var creditNote: ResourceID

    @Argument(help: "Credit note item ID or URL")
    var id: ResourceID

    @Option(name: .long, help: "Item description")
    var description: String?

    @Option(name: .long, help: "Item type (default: the item's current type, which FreeAgent would otherwise clear)")
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
        let itemPayload = try await Components.Schemas.CreditNoteItemPayload(
            id: id.value,
            description: description,
            itemType: resolvedItemType(client: client),
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

    func success(for _: Components.Schemas.CreditNoteResponse) -> String {
        "Updated credit note item \(id)"
    }

    // MARK: Private

    private func resolvedItemType(client: Client) async throws -> Components.Schemas.CreditNoteItemPayload.ItemTypePayload? {
        if let itemType {
            return itemType
        }

        let items = try await client.showCreditNote(.init(path: .init(id: creditNote.value)))
            .ok.body.json.creditNote.creditNoteItems

        return items?
            .first { ResourceID($0.url) == id }?
            .itemType
            .flatMap(Components.Schemas.CreditNoteItemPayload.ItemTypePayload.init(rawValue:))
    }
}
