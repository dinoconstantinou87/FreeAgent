import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExpenseListCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List expenses"
    )

    @Option(name: .long, help: "Maximum number of expenses to fetch")
    var limit = ListLimit.default

    func run(client: Client) async throws -> Components.Schemas.ExpenseListResponse? {
        let expenses = try await Paginator.collect(limit: limit.value) { page, perPage in
            let ok = try await client.listAllExpenses(.init(query: .init(page: page, perPage: perPage))).ok

            return (try ok.body.json.expenses, ok.headers.xTotalCount)
        }

        return .init(expenses: expenses)
    }
}
