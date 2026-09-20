import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExpenseListCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List expenses"
    )

    func run(client: Client) async throws -> Components.Schemas.ExpenseListResponse? {
        let input = Operations.ListAllExpenses.Input()

        return try await client.listAllExpenses(input)
            .ok.body.json
    }
}
