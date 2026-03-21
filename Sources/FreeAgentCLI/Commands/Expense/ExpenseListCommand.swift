import ArgumentParser
import Foundation
import FreeAgentAPI
import OpenAPIRuntime

struct ExpenseListCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List expenses"
    )

    func run(client: Client) async throws -> OpenAPIObjectContainer? {
        let input = Operations.ListAllExpenses.Input()

        return try await client.listAllExpenses(input)
            .ok.body.json.additionalProperties
    }
}
