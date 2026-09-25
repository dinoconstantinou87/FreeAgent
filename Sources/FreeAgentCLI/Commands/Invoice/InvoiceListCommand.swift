import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceListCommand: ListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List invoices"
    )

    static let noun = "invoices"

    static let columns: [Field<Components.Schemas.Invoice>] = [
        Field("ID") { .id(url: $0.url) },
        Field("Reference") { .text($0.reference) },
        Field("Contact") { .text($0.contactName) },
        Field("Dated On") { .date($0.datedOn) },
        Field("Due On") { .date($0.dueOn) },
        Field("Status") { .status($0.status) },
        Field("Total") { .currency($0.totalValue, code: $0.currency) },
    ]

    @Option(name: .long, help: "Filter by view, or last_N_months (e.g. last_3_months)")
    var view: CustomInvoiceView?

    @Option(name: .long, help: "Filter invoices by contact ID")
    var contact: String?

    @Option(name: .long, help: "Filter invoices by project ID")
    var project: String?

    @Option(name: .long, help: "Include invoice items nested within each invoice")
    var nestedInvoiceItems: Bool?

    @Option(name: .long, help: "Filter invoices by currency code")
    var currency: String?

    @Option(name: .long, help: "Show invoices updated after this timestamp")
    var updatedSince: String?

    @Option(name: .long, help: "Sort order")
    var sort: Operations.ListInvoices.Input.Query.SortPayload?

    @OptionGroup var pagination: PaginationOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client, page: Int) async throws -> (response: Components.Schemas.InvoiceListResponse, totalCount: Int?) {
        let ok = try await client.listInvoices(
            .init(query: .init(
                nestedInvoiceItems: nestedInvoiceItems,
                contact: contact,
                project: project,
                currency: currency,
                view: view,
                updatedSince: updatedSince,
                sort: sort,
                page: page,
                perPage: pagination.size
            ))
        ).ok

        return (try ok.body.json, ok.headers.xTotalCount)
    }

    func items(in response: Components.Schemas.InvoiceListResponse) -> [Components.Schemas.Invoice] {
        response.invoices
    }
}
