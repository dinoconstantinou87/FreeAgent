import ArgumentParser
import Foundation
import FreeAgentAPI

struct CreditNoteShowCommand: ShowCommand {
    typealias PricedItem = (item: Components.Schemas.InvoiceItem, currency: Components.Schemas.Currency?)

    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show credit note details"
    )

    static let title = "Credit Note"

    static let tables = [
        FieldTable<Components.Schemas.CreditNote>("Items", items: { creditNote in
            creditNote.creditNoteItems?.map { (item: $0, currency: creditNote.currency) }
        }) {
            itemColumns
        }
    ]

    static var sections: [FieldSection<Components.Schemas.CreditNote>] {
        FieldSection("Details") {
            Field("Reference") { .text($0.reference) }
            Field("Contact") { .text($0.contactName) }
            Field("Client Contact") { .text($0.clientContactName) }
            Field("Status") { .status($0.status) }
            Field("PO Reference") { .text($0.poReference) }
            Field("Payment Terms") { .text($0.paymentTermsInDays.map { "\($0) days" }) }
            Field("Comments") { .text($0.comments) }
        }
        FieldSection("Dates") {
            Field("Dated On") { .date($0.datedOn) }
            Field("Due On") { .date($0.dueOn) }
            Field("Refunded On") { .date($0.refundedOn) }
            Field("Written Off") { .date($0.writtenOffDate) }
            Field("Created") { .timestamp($0.createdAt) }
            Field("Updated") { .timestamp($0.updatedAt) }
        }
        FieldSection("Amounts") {
            Field("Net") { .currency($0.netValue, code: $0.currency) }
            Field("Sales Tax") { .currency($0.salesTaxValue, code: $0.currency) }
            Field("Second Sales Tax") { .currency($0.secondSalesTaxValue, code: $0.currency) }
            Field("Discount") { .percent($0.discountPercent) }
            Field("Total") { .currency($0.totalValue, code: $0.currency) }
            Field("Refunded") { .currency($0.refundedValue, code: $0.currency) }
            Field("Due") { .currency($0.dueValue, code: $0.currency) }
        }
        FieldSection("IDs") {
            Field("Credit Note") { .id(url: $0.url) }
            Field("Contact") { .id(url: $0.contact) }
            Field("Project") { .id(url: $0.project) }
            Field("Bank Account") { .id(url: $0.bankAccount) }
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

    @Argument(help: "Credit note ID or URL")
    var id: ResourceID

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.CreditNoteResponse {
        try await client.showCreditNote(.init(path: .init(id: id.value))).ok.body.json
    }

    func record(in response: Components.Schemas.CreditNoteResponse) -> Components.Schemas.CreditNote {
        response.creditNote
    }
}
