import ArgumentParser
import Foundation
import FreeAgentAPI

struct UserDeleteCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a user",
        discussion: "A user with timeslips, expenses or other records cannot be deleted, but can be hidden instead with 'freeagent user update <id> --hidden true'."
    )

    @Argument(help: "User ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    var confirmation: String {
        "Delete user \(id)?"
    }

    func perform(client: Client) async throws -> EmptyResponse {
        let input = Operations.DeleteUser.Input(
            path: .init(id: id.value)
        )

        _ = try await client.deleteUser(input).ok

        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Deleted user \(id)"
    }
}
