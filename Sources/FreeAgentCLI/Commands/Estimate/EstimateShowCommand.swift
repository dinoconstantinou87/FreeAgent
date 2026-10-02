import ArgumentParser
import Foundation
import FreeAgentAPI

struct EstimateShowCommand: ShowCommand {
    typealias PricedItem = (item: Components.Schemas.EstimateItem, currency: String?)

    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show estimate details"
    )

    static let title = "Estimate"

    static let tables = [
        FieldTable<Components.Schemas.Estimate>("Items", items: { estimate in
            estimate.estimateItems?.map { (item: $0, currency: estimate.currency) }
        }) {
            itemColumns
        }
    ]

    static var sections: [FieldSection<Components.Schemas.Estimate>] {
        FieldSection("Details") {
            Field("Reference") { .text($0.reference) }
            Field("Type") { .text($0.estimateType) }
            Field("Contact") { .text($0.contactName) }
            Field("Client Contact") { .text($0.clientContactName) }
            Field("Status") { .status($0.status) }
            Field("Notes") { .text($0.notes) }
        }
        FieldSection("Dates") {
            Field("Dated On") { .date($0.datedOn) }
            Field("Created") { .timestamp($0.createdAt) }
            Field("Updated") { .timestamp($0.updatedAt) }
        }
        FieldSection("Amounts") {
            Field("Net") { .currency($0.netValue, code: $0.currency) }
            Field("Sales Tax") { .currency($0.salesTaxValue, code: $0.currency) }
            Field("Discount") { .percent($0.discountPercent) }
            Field("Total") { .currency($0.totalValue, code: $0.currency) }
        }
        FieldSection("IDs") {
            Field("Estimate") { .id(url: $0.url) }
            Field("Contact") { .id(url: $0.contact) }
            Field("Project") { .id(url: $0.project) }
            Field("Invoice") { .id(url: $0.invoice) }
        }
    }

    @FieldBuilder<PricedItem>
    static var itemColumns: [Field<PricedItem>] {
        Field("ID") { .id(url: $0.item.url) }
        Field("Description") { .text($0.item.description) }
        Field("Type") { .text($0.item.itemType) }
        Field("Quantity") { .text($0.item.quantity) }
        Field("Price") { .currency($0.item.price, code: $0.currency) }
        Field("Sales Tax") { .percent($0.item.salesTaxRate) }
    }

    @Argument(help: "Estimate ID or URL")
    var id: ResourceID

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.EstimateResponse {
        try await client.showEstimate(.init(path: .init(id: id.value))).ok.body.json
    }

    func record(in response: Components.Schemas.EstimateResponse) -> Components.Schemas.Estimate {
        response.estimate
    }
}
