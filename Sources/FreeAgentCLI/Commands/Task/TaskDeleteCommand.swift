import ArgumentParser
import Foundation
import FreeAgentAPI

struct TaskDeleteCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a task",
        discussion: "A task with timeslips cannot be deleted, but can be marked Completed or Hidden instead."
    )

    @Argument(help: "Task ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    var confirmation: String {
        "Delete task \(id)?"
    }

    func perform(client: Client) async throws -> EmptyResponse {
        let input = Operations.DeleteTask.Input(
            path: .init(id: id.value)
        )

        _ = try await client.deleteTask(input).ok

        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Deleted task \(id)"
    }
}
