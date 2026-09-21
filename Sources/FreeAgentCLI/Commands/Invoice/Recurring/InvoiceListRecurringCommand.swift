import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceListRecurringCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List recurring invoices"
    )

    @Option(name: .long, help: "Filter by view")
    var view: Operations.ListAllRecurringInvoices.Input.Query.ViewPayload?

    @Option(name: .long, help: "Filter by contact ID")
    var contact: String?

    @Option(name: .long, help: "Maximum number of recurring invoices to fetch")
    var limit = ListLimit.default

    func run(client: Client) async throws -> Components.Schemas.RecurringInvoiceListResponse? {
        let invoices = try await Paginator.collect(limit: limit.value) { page, perPage in
            let ok = try await client.listAllRecurringInvoices(
                .init(query: .init(view: view, contact: contact, page: page, perPage: perPage))
            ).ok

            return (try ok.body.json.recurringInvoices, ok.headers.xTotalCount)
        }

        return .init(recurringInvoices: invoices)
    }
}
