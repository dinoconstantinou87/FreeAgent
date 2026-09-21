import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceListCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List invoices"
    )

    @Option(name: .long, help: "Filter by view")
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

    @Option(name: .long, help: "Maximum number of invoices to fetch")
    var limit = ListLimit.default

    func run(client: Client) async throws -> Components.Schemas.InvoiceListResponse? {
        let invoices = try await Paginator.collect(limit: limit.value) { page, perPage in
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
                    perPage: perPage
                ))
            ).ok

            return (try ok.body.json.invoices, ok.headers.xTotalCount)
        }

        return .init(invoices: invoices)
    }
}
