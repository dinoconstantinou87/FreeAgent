import ArgumentParser
import Foundation
import FreeAgentAPI

struct ContactCreateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new contact"
    )

    @Option(name: .long, help: "First name")
    var firstName: String?

    @Option(name: .long, help: "Last name")
    var lastName: String?

    @Option(name: .long, help: "Organisation name")
    var organisationName: String?

    @Option(name: .long, help: "Email address")
    var email: String?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.ContactResponse {
        let contactPayload = Components.Schemas.ContactCreatePayload(
            email: email,
            firstName: firstName,
            lastName: lastName,
            organisationName: organisationName
        )

        let input = Operations.CreateContact.Input(
            body: .json(.init(contact: contactPayload))
        )

        return try await client.createContact(input)
            .created.body.json
    }

    func success(for response: Components.Schemas.ContactResponse) -> String {
        "Created contact \(response.contact.url)"
    }
}
