import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceListRecurringCommand: ListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List recurring invoices"
    )

    static let noun = "recurring invoices"

    static let columns: [ListColumn<Components.Schemas.RecurringInvoice>] = [
        ListColumn("ID") { .id(url: $0.url) },
        ListColumn("Reference") { .text($0.reference) },
        ListColumn("Contact") { .text($0.contactName) },
        ListColumn("Frequency") { .text($0.frequency) },
        ListColumn("Next Recurs On") { .date($0.nextRecursOn) },
        ListColumn("Status") { .status($0.recurringStatus) },
        ListColumn("Total") { .currency($0.totalValue, code: $0.currency) },
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
