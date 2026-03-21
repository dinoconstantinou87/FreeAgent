import ArgumentParser
import Foundation
import FreeAgentAPI
import OpenAPIRuntime

struct ExpenseShowCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show expense details"
    )

    @Argument(help: "Expense ID")
    var id: String

    func run(client: Client) async throws -> OpenAPIObjectContainer? {
        let input = Operations.GetASingleExpense.Input(
            path: .init(id: id)
        )

        return try await client.getASingleExpense(input)
            .ok.body.json.additionalProperties
    }
}
