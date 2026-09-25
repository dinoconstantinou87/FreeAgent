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
    }

    @OptionGroup var pagination: PaginationOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client, page: Int) async throws -> (response: Components.Schemas.ExpenseListResponse, totalCount: Int?) {
        let ok = try await client.listAllExpenses(.init(query: .init(page: page, perPage: pagination.size))).ok

        return (try ok.body.json, ok.headers.xTotalCount)
    }

    func items(in response: Components.Schemas.ExpenseListResponse) -> [Components.Schemas.Expense] {
        response.expenses
    }
}
