import ArgumentParser
import Foundation
import FreeAgentAPI

struct PriceListItemUpdateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update a price list item",
        discussion: "Fields left out are kept."
    )

    @Argument(help: "Price list item ID or URL")
    var id: ResourceID

    @Option(name: .long, help: "Code, unique and at most 100 characters")
    var code: String?

    @Option(name: .long, help: "Description")
    var description: String?

    @Option(name: .long, parsing: .unconditional, help: "Item type")
    var itemType: Components.Schemas.PriceListItemType?

    @OptionGroup var priceListItem: PriceListItemOptions

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.PriceListItemResponse {
        let input = Operations.UpdatePriceListItem.Input(
            path: .init(id: id.value),
            body: .json(.init(priceListItem: priceListItem.updatePayload(
                code: code,
                description: description,
                itemType: itemType
            )))
        )

        return try await client.updatePriceListItem(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.PriceListItemResponse) -> String {
        "Updated price list item \(id)"
    }
}
