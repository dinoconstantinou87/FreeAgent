import ArgumentParser
import Foundation
import FreeAgentAPI

struct UserUpdateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update a user",
        discussion: "Fields left out are kept, and an empty --ni-number or --unique-tax-reference removes it."
    )

    @Argument(help: "User ID or URL - defaults to the logged-in user")
    var id: ResourceID?

    @Option(name: .long, help: "Login email address")
    var email: String?

    @Option(name: .long, help: "First name")
    var firstName: String?

    @Option(name: .long, help: "Last name")
    var lastName: String?

    @Option(name: .long, help: "Role in the company")
    var role: Components.Schemas.UserRole?

    @OptionGroup var profile: UserProfileOptions

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.UserResponse {
        let userPayload = profile.updatePayload(
            email: email,
            firstName: firstName,
            lastName: lastName,
            role: role
        )

        guard let id else {
            return try await client.updateCurrentUser(.init(body: .json(.init(user: userPayload))))
                .ok.body.json
        }

        let input = Operations.UpdateUser.Input(
            path: .init(id: id.value),
            body: .json(.init(user: userPayload))
        )

        return try await client.updateUser(input)
            .ok.body.json
    }

    func success(for response: Components.Schemas.UserResponse) -> String {
        "Updated user \(ResourceID(response.user.url))"
    }
}
