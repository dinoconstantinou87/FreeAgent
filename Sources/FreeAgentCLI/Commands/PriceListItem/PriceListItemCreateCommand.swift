import ArgumentParser
import Foundation
import FreeAgentAPI

struct PriceListItemCreateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a price list item",
        discussion: "The quantity and price default to 0, the VAT status to out_of_scope and the category to Sales (001)."
    )

    @Option(name: .long, help: "Code, unique and at most 100 characters")
    var code: String

    @Option(name: .long, help: "Description")
    var description: String

    @Option(name: .long, parsing: .unconditional, help: "Item type")
    var itemType: Components.Schemas.PriceListItemType

    @OptionGroup var priceListItem: PriceListItemOptions

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.PriceListItemResponse {
        let input = Operations.CreatePriceListItem.Input(
            body: .json(.init(priceListItem: priceListItem.createPayload(
                code: code,
                description: description,
                itemType: itemType
            )))
        )

        return try await client.createPriceListItem(input)
            .created.body.json
    }

    func success(for response: Components.Schemas.PriceListItemResponse) -> String {
        "Created price list item \(response.priceListItem.url)"
    }
}
