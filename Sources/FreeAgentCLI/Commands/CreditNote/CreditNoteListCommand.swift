import ArgumentParser
import Foundation
import FreeAgentAPI

struct CreditNoteListCommand: AsyncPaginatedListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List credit notes"
    )

    static let noun = "credit notes"

    static var columns: [Field<Components.Schemas.CreditNote>] {
        Field("ID") { .id(url: $0.url) }
        Field("Reference") { .text($0.reference) }
        Field("Contact") { .text($0.contactName) }
        Field("Dated On") { .date($0.datedOn) }
        Field("Due On") { .date($0.dueOn) }
        Field("Status") { .status($0.status) }
        Field("Total") { .currency($0.totalValue, code: $0.currency) }
    }

    @Option(name: .long, help: "Filter by view, or last_N_months (e.g. last_3_months)")
    var view: Components.Schemas.CreditNoteView?

    @Option(name: .long, help: "Filter by contact ID or URL")
    var contact: ResourceID?

    @Option(name: .long, help: "Filter by project ID or URL")
    var project: ResourceID?

    @Option(name: .long, help: "Show credit notes dated on or after this date (YYYY-MM-DD)")
    var fromDate: String?

    @Option(name: .long, help: "Show credit notes dated on or before this date (YYYY-MM-DD)")
    var toDate: String?

    @Option(name: .long, help: "Show credit notes updated after this timestamp")
    var updatedSince: String?

    @Option(name: .long, parsing: .unconditional, help: "Sort order")
    var sort: Operations.ListCreditNotes.Input.Query.SortPayload?

    @Option(name: .long, help: "Include credit note items nested within each credit note")
    var nestedCreditNoteItems: Bool?

    @OptionGroup var pagination: PaginationOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(
        client: Client,
        page: Int
    ) async throws -> (response: Components.Schemas.CreditNoteListResponse, totalCount: Int?) {
        let ok = try await client.listCreditNotes(
            .init(query: .init(
                nestedCreditNoteItems: nestedCreditNoteItems,
                contact: contact?.value,
                project: project?.value,
                view: view,
                fromDate: fromDate,
                toDate: toDate,
                updatedSince: updatedSince,
                sort: sort,
                page: page,
                perPage: pagination.size
            ))
        ).ok

        return (try ok.body.json, ok.headers.xTotalCount)
    }

    func items(in response: Components.Schemas.CreditNoteListResponse) -> [Components.Schemas.CreditNote] {
        response.creditNotes
    }
}
