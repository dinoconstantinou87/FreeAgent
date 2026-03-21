import ArgumentParser
import Foundation
import FreeAgentAPI
import OpenAPIRuntime

struct CategoryListCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List categories"
    )

    func run(client: Client) async throws -> OpenAPIObjectContainer? {
        let input = Operations.ListCategories.Input()

        return try await client.listCategories(input)
            .ok.body.json.additionalProperties
    }
}
