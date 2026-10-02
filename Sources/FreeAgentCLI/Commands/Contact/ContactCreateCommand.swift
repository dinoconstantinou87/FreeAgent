import ArgumentParser
import Foundation
import FreeAgentAPI

struct ContactCreateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new contact",
        discussion: "A contact needs an organisation name, or a first and last name."
    )

    @OptionGroup var contact: ContactOptions

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.ContactResponse {
        let input = Operations.CreateContact.Input(
            body: .json(.init(contact: contact.createPayload))
        )

        return try await client.createContact(input)
            .created.body.json
    }

    func success(for response: Components.Schemas.ContactResponse) -> String {
        "Created contact \(response.contact.url)"
    }
}
