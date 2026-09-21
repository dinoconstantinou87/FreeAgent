import ArgumentParser
import Foundation
import FreeAgentAPI

struct CategoryListCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List categories"
    )

    func run(client: Client) async throws -> Components.Schemas.CategoryListResponse? {
        let input = Operations.ListCategories.Input()

        return try await client.listCategories(input)
            .ok.body.json
    }
}
