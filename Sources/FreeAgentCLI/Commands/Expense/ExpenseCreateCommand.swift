import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExpenseCreateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create an expense",
        discussion: "A mileage claim uses the Mileage category, 249, with --mileage and --vehicle-type in place of --gross-value."
    )

    @Option(name: .long, help: "Category ID or URL, e.g. 285, or 249 for a mileage claim")
    var category: ResourceID

    @Option(name: .long, help: "Date of the expense (YYYY-MM-DD)")
    var datedOn: String

    @Option(name: .long, help: "Description of the expense")
    var description: String

    @Option(
        name: .long,
        help: "Engine of a car or motorcycle mileage claim, as listed by 'expense mileage-settings' (default: Petrol)"
    )
    var engineType: Components.Schemas.ExpenseEngineType?

    @Option(
        name: .long,
        help: "Engine size of a mileage claim, as listed by 'expense mileage-settings' - an unknown size becomes the first"
    )
    var engineSize: String?

    @OptionGroup var expense: ExpenseOptions

    @OptionGroup var user: UserOptions

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.ExpenseResponse {
        let expensePayload = try await expense.createPayload(
            user: user.id(client: client),
            category: category.value,
            datedOn: datedOn,
            description: description,
            engineType: engineType,
            engineSize: engineSize
        )

        let input = Operations.CreateExpense.Input(
            body: .json(.init(expense: expensePayload))
        )

        return try await client.createExpense(input)
            .created.body.json
    }

    func success(for response: Components.Schemas.ExpenseResponse) -> String {
        "Created expense \(response.expense.url)"
    }
}
