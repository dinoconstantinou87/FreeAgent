import ArgumentParser
import Foundation
import FreeAgentAPI

struct EstimateUpdateItemCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "update-item",
        abstract: "Update an estimate item"
    )

    @Argument(help: "Estimate item ID or URL")
    var id: ResourceID

    @Option(name: .long, help: "Item description")
    var description: String?

    @Option(name: .long, help: "Item type")
    var itemType: Components.Schemas.EstimateItemPayload.ItemTypePayload?

    @Option(name: .long, help: "Item quantity")
    var quantity: Double?

    @Option(name: .long, parsing: .unconditional, help: "Item price")
    var price: Double?

    @Option(name: .long, help: "Sales tax rate, e.g. 20 - FreeAgent charges -1% on a new item without one")
    var salesTaxRate: Double?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.EstimateItemResponse {
        let itemPayload = Components.Schemas.EstimateItemPayload(
            description: description,
            itemType: itemType,
            price: price,
            quantity: quantity,
            salesTaxRate: salesTaxRate
        )

        let input = Operations.UpdateEstimateItem.Input(
            path: .init(id: id.value),
            body: .json(.init(estimateItem: itemPayload))
        )

        return try await client.updateEstimateItem(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.EstimateItemResponse) -> String {
        "Updated estimate item \(id)"
    }
}
