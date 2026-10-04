import ArgumentParser
import Foundation
import FreeAgentAPI

struct PriceListItemShowCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show price list item details"
    )

    static let title = "Price List Item"

    static var sections: [FieldSection<Components.Schemas.PriceListItem>] {
        FieldSection("Details") {
            Field("Code") { .text($0.code) }
            Field("Description") { .text($0.description) }
            Field("Item Type") { .text($0.itemType) }
            Field("Quantity") { .text($0.quantity) }
            Field("Price") { .currency($0.price, code: nil) }
        }
        FieldSection("Tax") {
            Field("VAT Status") { .text($0.vatStatus) }
            Field("Sales Tax Rate") { .percent($0.salesTaxRate) }
            Field("Second Sales Tax Rate") { .percent($0.secondSalesTaxRate) }
        }
        FieldSection("Dates") {
            Field("Created") { .timestamp($0.createdAt) }
            Field("Updated") { .timestamp($0.updatedAt) }
        }
        FieldSection("IDs") {
            Field("Price List Item") { .id(url: $0.url) }
            Field("Category") { .id(url: $0.category) }
            Field("Stock Item") { .id(url: $0.stockItem) }
        }
    }

    @Argument(help: "Price list item ID or URL")
    var id: ResourceID

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.PriceListItemResponse {
        try await client.showPriceListItem(.init(path: .init(id: id.value))).ok.body.json
    }

    func record(in response: Components.Schemas.PriceListItemResponse) -> Components.Schemas.PriceListItem {
        response.priceListItem
    }
}
