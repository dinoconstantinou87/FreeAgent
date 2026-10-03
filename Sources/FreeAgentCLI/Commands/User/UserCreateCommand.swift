import ArgumentParser
import Foundation
import FreeAgentAPI

struct UserCreateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a user",
        discussion: "The permission level defaults to No Access, and an Accountant needs Tax, Accounting & Users or Full."
    )

    @Option(name: .long, help: "Login email address")
    var email: String

    @Option(name: .long, help: "First name")
    var firstName: String

    @Option(name: .long, help: "Last name")
    var lastName: String

    @Option(name: .long, help: "Role in the company")
    var role: Components.Schemas.UserRole

    @OptionGroup var profile: UserProfileOptions

    @Option(name: .long, help: "Email the user an invitation to set their password")
    var sendInvitation = false

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.UserResponse {
        let userPayload = profile.createPayload(
            email: email,
            firstName: firstName,
            lastName: lastName,
            role: role,
            sendInvitation: sendInvitation
        )

        let input = Operations.CreateUser.Input(
            body: .json(.init(user: userPayload))
        )

        return try await client.createUser(input)
            .created.body.json
    }

    func success(for response: Components.Schemas.UserResponse) -> String {
        "Created user \(response.user.url)"
    }
}
