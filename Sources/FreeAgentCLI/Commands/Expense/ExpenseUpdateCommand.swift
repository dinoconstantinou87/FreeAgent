import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExpenseUpdateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update an expense",
        discussion: """
            Fields left out are kept, and an empty --receipt-reference removes it. A mileage claim's engine can't be \
            changed. The attachment is managed with 'freeagent expense attachment'.
            """
    )

    @Argument(help: "Expense ID or URL")
    var id: ResourceID

    @Option(name: .long, help: "Category ID or URL, e.g. 285")
    var category: ResourceID?

    @Option(name: .long, help: "Date of the expense (YYYY-MM-DD)")
    var datedOn: String?

    @Option(name: .long, help: "Description of the expense")
    var description: String?

    @Option(name: .long, help: "Claimant's user ID or URL")
    var user: ResourceID?

    @OptionGroup var expense: ExpenseOptions

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.ExpenseResponse {
        let expensePayload = expense.updatePayload(
            user: user?.value,
            category: category?.value,
            datedOn: datedOn,
            description: description
        )

        let input = Operations.UpdateExpense.Input(
            path: .init(id: id.value),
            body: .json(.init(expense: expensePayload))
        )

        return try await client.updateExpense(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.ExpenseResponse) -> String {
        "Updated expense \(id)"
    }
}
