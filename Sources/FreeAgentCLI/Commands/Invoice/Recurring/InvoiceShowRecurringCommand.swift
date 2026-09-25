import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceShowRecurringCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show recurring invoice details"
    )

    static let title = "Recurring Invoice"

    static let sections: [FieldSection<Components.Schemas.RecurringInvoice>] = [
        FieldSection("Details", fields: [
            Field("Reference") { .text($0.reference) },
            Field("Contact") { .text($0.contactName) },
            Field("Client Contact") { .text($0.clientContactName) },
            Field("Status") { .status($0.recurringStatus) },
            Field("Frequency") { .text($0.frequency) },
            Field("Payment Terms") { .text($0.paymentTermsInDays.map { "\($0) days" }) },
            Field("Comments") { .text($0.comments) },
        ]),
        FieldSection("Dates", fields: [
            Field("Dated On") { .date($0.datedOn) },
            Field("Next Recurs On") { .date($0.nextRecursOn) },
            Field("Ends On") { .date($0.recurringEndDate) },
            Field("Created") { .timestamp($0.createdAt) },
            Field("Updated") { .timestamp($0.updatedAt) },
        ]),
        FieldSection("Amounts", fields: [
            Field("Net") { .currency($0.netValue, code: $0.currency) },
            Field("Discount") { .percent($0.discountPercent) },
            Field("Sales Tax") { .currency($0.salesTaxValue, code: $0.currency) },
            Field("Total") { .currency($0.totalValue, code: $0.currency) },
            Field("Due") { .currency($0.dueValue, code: $0.currency) },
        ]),
        FieldSection("IDs", fields: [
            Field("Recurring Invoice") { .id(url: $0.url) },
            Field("Contact") { .id(url: $0.contact) },
            Field("Bank Account") { .id(url: $0.bankAccount) },
            Field("Profile") { .text($0.profileId) },
        ]),
    ]

    static let tables = [
        FieldTable<Components.Schemas.RecurringInvoice>("Items", columns: InvoiceShowCommand.itemColumns) { invoice in
            invoice.recurringInvoiceItems?.map { (item: $0, currency: invoice.currency) }
        }
    ]

    @Argument(help: "Recurring invoice ID")
    var id: String

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.RecurringInvoiceResponse {
        try await client.showRecurringInvoice(.init(path: .init(id: id))).ok.body.json
    }

    func record(in response: Components.Schemas.RecurringInvoiceResponse) -> Components.Schemas.RecurringInvoice {
        response.recurringInvoice
    }
}
