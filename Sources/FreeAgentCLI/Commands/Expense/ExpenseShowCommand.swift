import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExpenseShowCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show expense details"
    )

    @Argument(help: "Expense ID")
    var id: String

    func run(client: Client) async throws -> Components.Schemas.ExpenseResponse? {
        let input = Operations.GetASingleExpense.Input(
            path: .init(id: id)
        )

        return try await client.getASingleExpense(input)
            .ok.body.json
    }
}
