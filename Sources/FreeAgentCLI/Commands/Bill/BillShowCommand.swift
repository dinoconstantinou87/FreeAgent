import ArgumentParser
import Foundation
import FreeAgentAPI

struct BillShowCommand: ShowCommand {
    typealias PricedItem = (item: Components.Schemas.BillItem, currency: Components.Schemas.Currency?)

    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show bill details"
    )

    static let title = "Bill"

    static let tables = [
        FieldTable<Components.Schemas.Bill>("Items", items: { bill in
            bill.billItems?.map { (item: $0, currency: bill.currency) }
        }) {
            itemColumns
        }
    ]

    static var sections: [FieldSection<Components.Schemas.Bill>] {
        FieldSection("Details") {
            Field("Reference") { .text($0.reference) }
            Field("Contact") { .text($0.contactName) }
            Field("Status") { .status($0.longStatus) }
            Field("Recurring") { .text($0.recurring) }
            Field("Comments") { .text($0.comments) }
            Field("Locked") { .text($0.lockedReason) }
        }
        FieldSection("Dates") {
            Field("Dated On") { .date($0.datedOn) }
            Field("Due On") { .date($0.dueOn) }
            Field("Paid On") { .date($0.paidOn) }
            Field("Recurring Until") { .date($0.recurringEndDate) }
            Field("Created") { .timestamp($0.createdAt) }
            Field("Updated") { .timestamp($0.updatedAt) }
        }
        FieldSection("Amounts") {
            Field("Net") { .currency($0.netValue, code: $0.currency) }
            Field("Sales Tax") { .currency($0.salesTaxValue, code: $0.currency) }
            Field("Total") { .currency($0.totalValue, code: $0.currency) }
            Field("Paid") { .currency($0.paidValue, code: $0.currency) }
            Field("Due") { .currency($0.dueValue, code: $0.currency) }
        }
        FieldSection("IDs") {
            Field("Bill") { .id(url: $0.url) }
            Field("Contact") { .id(url: $0.contact) }
            Field("Project") { .id(url: $0.project) }
        }
    }

    @FieldBuilder<PricedItem>
    static var itemColumns: [Field<PricedItem>] {
        Field("ID") { .id(url: $0.item.url) }
        Field("Description") { .text($0.item.description) }
        Field("Category") { .id(url: $0.item.category) }
        Field("Total") { .currency($0.item.totalValue, code: $0.currency) }
        Field("Sales Tax") { .percent($0.item.salesTaxRate) }
    }

    @Argument(help: "Bill ID or URL")
    var id: ResourceID

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.BillResponse {
        try await client.showBill(.init(path: .init(id: id.value))).ok.body.json
    }

    func record(in response: Components.Schemas.BillResponse) -> Components.Schemas.Bill {
        response.bill
    }
}
