import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceShowCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show invoice details"
    )

    static let title = "Invoice"

    static let sections: [FieldSection<Components.Schemas.Invoice>] = [
        FieldSection("Details", fields: [
            Field("Reference") { .text($0.reference) },
            Field("Contact") { .text($0.contactName) },
            Field("Client Contact") { .text($0.clientContactName) },
            Field("Status") { .status($0.status) },
            Field("PO Reference") { .text($0.poReference) },
            Field("Payment Terms") { .text($0.paymentTermsInDays.map { "\($0) days" }) },
            Field("Comments") { .text($0.comments) },
        ]),
        FieldSection("Dates", fields: [
            Field("Dated On") { .date($0.datedOn) },
            Field("Due On") { .date($0.dueOn) },
            Field("Paid On") { .date($0.paidOn) },
            Field("Written Off") { .date($0.writtenOffDate) },
            Field("Created") { .timestamp($0.createdAt) },
            Field("Updated") { .timestamp($0.updatedAt) },
        ]),
        FieldSection("Amounts", fields: [
            Field("Net") { .currency($0.netValue, code: $0.currency) },
            Field("Sales Tax") { .currency($0.salesTaxValue, code: $0.currency) },
            Field("Second Sales Tax") { .currency($0.secondSalesTaxValue, code: $0.currency) },
            Field("Discount") { .percent($0.discountPercent) },
            Field("Total") { .currency($0.totalValue, code: $0.currency) },
            Field("Paid") { .currency($0.paidValue, code: $0.currency) },
            Field("Due") { .currency($0.dueValue, code: $0.currency) },
        ]),
        FieldSection("IDs", fields: [
            Field("Invoice") { .id(url: $0.url) },
            Field("Contact") { .id(url: $0.contact) },
            Field("Project") { .id(url: $0.project) },
            Field("Bank Account") { .id(url: $0.bankAccount) },
            Field("Recurring Invoice") { .id(url: $0.recurringInvoice) },
        ]),
    ]

    static let tables = [
        FieldTable<Components.Schemas.Invoice>("Items", columns: itemColumns) { invoice in
            invoice.invoiceItems?.map { (item: $0, currency: invoice.currency) }
        }
    ]

    static let itemColumns: [Field<(item: Components.Schemas.InvoiceItem, currency: String?)>] = [
        Field("Description") { .text($0.item.description) },
        Field("Type") { .text($0.item.itemType) },
        Field("Quantity") { .text($0.item.quantity) },
        Field("Price") { .currency($0.item.price, code: $0.currency) },
        Field("Sales Tax") { .percent($0.item.salesTaxRate) },
    ]

    @Argument(help: "Invoice ID")
    var id: String

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.InvoiceResponse {
        try await client.showInvoice(.init(path: .init(id: id))).ok.body.json
    }

    func record(in response: Components.Schemas.InvoiceResponse) -> Components.Schemas.Invoice {
        response.invoice
    }
}
