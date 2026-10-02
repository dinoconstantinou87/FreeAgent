import ArgumentParser
import Foundation
import FreeAgentAPI

struct EstimateCreateItemCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create-item",
        abstract: "Create estimate item"
    )

    @Argument(help: "Estimate ID or URL")
    var estimate: ResourceID

    @Option(name: .long, help: "Item description")
    var description: String

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
        let estimateItemPayload = Components.Schemas.EstimateItemPayload(
            description: description,
            itemType: itemType,
            price: price,
            quantity: quantity,
            salesTaxRate: salesTaxRate
        )

        let input = Operations.CreateEstimateItem.Input(
            body: .json(.init(estimate: estimate.value, estimateItem: estimateItemPayload))
        )

        return try await client.createEstimateItem(input)
            .created.body.json
    }

    func success(for response: Components.Schemas.EstimateItemResponse) -> String {
        "Created item \(response.estimateItem.url) on estimate \(estimate)"
    }
}
