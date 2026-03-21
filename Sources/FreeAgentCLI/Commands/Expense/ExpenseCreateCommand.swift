import ArgumentParser
import Foundation
import FreeAgentAPI
import OpenAPIRuntime

struct ExpenseCreateCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create an expense"
    )

    @Option(name: .long, help: "Category URL (e.g. https://api.freeagent.com/v2/categories/285)")
    var category: String

    @Option(name: .long, help: "Date of the expense (YYYY-MM-DD)")
    var datedOn: String

    @Option(name: .long, help: "Description of the expense")
    var description: String

    @Option(name: .long, help: "Gross value (e.g. -12.0)")
    var grossValue: String

    @Option(name: .long, help: "Sales tax rate (e.g. 20.0)")
    var salesTaxRate: String?

    @Option(name: .long, help: "Manual sales tax amount (e.g. 0.12)")
    var manualSalesTaxAmount: String?

    @Option(name: .long, help: "User URL (e.g. https://api.freeagent.com/v2/users/1)")
    var user: String?

    func run(client: Client) async throws -> OpenAPIObjectContainer? {
        let expensePayload = Components.Schemas.ExpensePayload(
            category: category,
            datedOn: datedOn,
            description: description,
            grossValue: grossValue,
            manualSalesTaxAmount: manualSalesTaxAmount,
            salesTaxRate: salesTaxRate,
            user: user
        )

        let input = Operations.CreateExpense.Input(
            body: .json(.init(expense: expensePayload))
        )

        return try await client.createExpense(input)
            .created.body.json.additionalProperties
    }
}
