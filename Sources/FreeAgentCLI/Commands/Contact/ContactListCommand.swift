import ArgumentParser
import Foundation
import FreeAgentAPI
import OpenAPIRuntime

struct ContactListCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List contacts"
    )

    func run(client: Client) async throws -> OpenAPIObjectContainer? {
        let input = Operations.ListContacts.Input()

        return try await client.listContacts(input)
            .ok.body.json.additionalProperties
    }
}
