import ArgumentParser
import Foundation
import FreeAgentAPI

struct ContactUpdateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update a contact",
        discussion: "Fields left out are kept, and an empty string removes a text field. A contact with no organisation name must keep its first and last name."
    )

    @Argument(help: "Contact ID or URL")
    var id: ResourceID

    @OptionGroup var contact: ContactOptions

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.ContactResponse {
        let input = Operations.UpdateContact.Input(
            path: .init(id: id.value),
            body: .json(.init(contact: contact.updatePayload))
        )

        return try await client.updateContact(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.ContactResponse) -> String {
        "Updated contact \(id)"
    }
}
