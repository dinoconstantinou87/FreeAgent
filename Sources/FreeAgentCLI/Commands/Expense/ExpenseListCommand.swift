import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExpenseListCommand: AsyncPaginatedListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List expenses"
    )

    static let noun = "expenses"

    static var columns: [Field<Components.Schemas.Expense>] {
        Field("ID") { .id(url: $0.url) }
        Field("Dated On") { .date($0.datedOn) }
        Field("Description") { .text($0.description) }
        Field("Gross Value") { .currency($0.grossValue, code: $0.currency) }
        Field("Recurring") { .text($0.recurring) }
    }

    @Option(name: .long, help: "Filter by view")
    var view: Operations.ListAllExpenses.Input.Query.ViewPayload?

    @Option(name: .long, help: "Filter by claimant's user ID or URL")
    var user: ResourceID?

    @Option(name: .long, help: "Filter by project ID or URL")
    var project: ResourceID?

    @Option(name: .long, help: "Show expenses dated on or after this date (YYYY-MM-DD)")
    var fromDate: String?

    @Option(name: .long, help: "Show expenses dated on or before this date (YYYY-MM-DD)")
    var toDate: String?

    @Option(name: .long, help: "Show expenses updated after this timestamp")
    var updatedSince: String?

    @Option(name: .long, parsing: .unconditional, help: "Sort order")
    var sort: Operations.ListAllExpenses.Input.Query.SortPayload?

    @OptionGroup var pagination: PaginationOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(
        client: Client,
        page: Int
    ) async throws -> (response: Components.Schemas.ExpenseListResponse, totalCount: Int?) {
        let ok = try await client.listAllExpenses(
            .init(query: .init(
                view: view,
                fromDate: fromDate,
                toDate: toDate,
                updatedSince: updatedSince,
                project: project?.value,
                user: user?.value,
                sort: sort,
                page: page,
                perPage: pagination.size
            ))
        ).ok

        return (try ok.body.json, ok.headers.xTotalCount)
    }

    func items(in response: Components.Schemas.ExpenseListResponse) -> [Components.Schemas.Expense] {
        response.expenses
    }
}
