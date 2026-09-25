import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceListRecurringCommand: ListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List recurring invoices"
    )

    static let noun = "recurring invoices"

    static let columns: [Field<Components.Schemas.RecurringInvoice>] = [
        Field("ID") { .id(url: $0.url) },
        Field("Reference") { .text($0.reference) },
        Field("Contact") { .text($0.contactName) },
        Field("Frequency") { .text($0.frequency) },
        Field("Next Recurs On") { .date($0.nextRecursOn) },
        Field("Status") { .status($0.recurringStatus) },
        Field("Total") { .currency($0.totalValue, code: $0.currency) },
    ]

    @Option(name: .long, help: "Filter by view")
    var view: Operations.ListAllRecurringInvoices.Input.Query.ViewPayload?

    @Option(name: .long, help: "Filter by contact ID")
    var contact: String?

    @OptionGroup var pagination: PaginationOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(
        client: Client,
        page: Int
    ) async throws -> (response: Components.Schemas.RecurringInvoiceListResponse, totalCount: Int?) {
        let ok = try await client.listAllRecurringInvoices(
            .init(query: .init(view: view, contact: contact, page: page, perPage: pagination.size))
        ).ok

        return (try ok.body.json, ok.headers.xTotalCount)
    }

    func items(in response: Components.Schemas.RecurringInvoiceListResponse) -> [Components.Schemas.RecurringInvoice] {
        response.recurringInvoices
    }
}
