import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExpenseShowCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show expense details"
    )

    static let title = "Expense"

    static var sections: [FieldSection<Components.Schemas.Expense>] {
        FieldSection("Details") {
            Field("Description") { .text($0.description) }
            Field("Receipt Reference") { .text($0.receiptReference) }
            Field("EC Status") { .text($0.ecStatus) }
            Field("Recurring") { .text($0.recurring) }
            Field("Stock Item Description") { .text($0.stockItemDescription) }
            Field("Stock Quantity") { .text($0.stockAlteringQuantity) }
            Field("Locked") { .text($0.lockedReason) }
        }
        FieldSection("Mileage") {
            Field("Mileage") { .text($0.mileage) }
            Field("Vehicle Type") { .text($0.vehicleType) }
            Field("Engine Type") { .text($0.engineType) }
            Field("Engine Size") { .text($0.engineSize) }
            Field("Reclaim Rate") { .currency($0.reclaimMileageRate, code: $0.currency) }
            Field("Rebill Rate") { .currency($0.rebillMileageRate, code: $0.currency) }
            Field("VAT Receipt") { .flag($0.haveVatReceipt) }
        }
        FieldSection("Rebilling") {
            Field("Project") { .text($0.projectName) }
            Field("Contact") { .text($0.contactName) }
            Field("Rebill Type") { .text($0.rebillType) }
            Field("Rebill Factor") { .text($0.rebillFactor) }
        }
        FieldSection("Amounts") {
            Field("Gross Value") { .currency($0.grossValue, code: $0.currency) }
            Field("Sales Tax Rate") { .percent($0.salesTaxRate) }
            Field("Sales Tax") { .currency($0.salesTaxValue, code: $0.currency) }
            Field("Sales Tax Status") { .status($0.salesTaxStatus) }
            Field("Second Sales Tax Rate") { .percent($0.secondSalesTaxRate) }
            Field("Second Sales Tax Status") { .status($0.secondSalesTaxStatus) }
            Field("Manual Sales Tax") { .currency($0.manualSalesTaxAmount, code: $0.currency) }
        }
        FieldSection("Dates") {
            Field("Dated On") { .date($0.datedOn) }
            Field("Next Recurs On") { .date($0.nextRecursOn) }
            Field("Recurring End") { .date($0.recurringEndDate) }
            Field("Created") { .timestamp($0.createdAt) }
            Field("Updated") { .timestamp($0.updatedAt) }
        }
        FieldSection("Attachment") {
            Field("File Name") { .text($0.attachment?.fileName) }
            Field("Content Type") { .text($0.attachment?.contentType) }
            Field("Size") { .bytes($0.attachment?.fileSize) }
        }
        FieldSection("IDs") {
            Field("Expense") { .id(url: $0.url) }
            Field("Category") { .id(url: $0.category) }
            Field("User") { .id(url: $0.user) }
            Field("Project") { .id(url: $0.project) }
            Field("Property") { .id(url: $0.property) }
            Field("Stock Item") { .id(url: $0.stockItem) }
            Field("Capital Asset") { .id(url: $0.capitalAsset) }
            Field("Rebill Project") { .id(url: $0.rebillToProject) }
            Field("Rebilled Invoice") { .id(url: $0.rebilledOnInvoice) }
            Field("Attachment") { .id(url: $0.attachment?.url) }
        }
    }

    @Argument(help: "Expense ID or URL")
    var id: ResourceID

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.ExpenseResponse {
        try await client.getASingleExpense(.init(path: .init(id: id.value))).ok.body.json
    }

    func record(in response: Components.Schemas.ExpenseResponse) -> Components.Schemas.Expense {
        response.expense
    }
}
