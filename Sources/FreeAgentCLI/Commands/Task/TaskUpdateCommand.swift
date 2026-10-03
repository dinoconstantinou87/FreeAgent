import ArgumentParser
import Foundation
import FreeAgentAPI

struct TaskUpdateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update a task",
        discussion: "Fields left out are kept. A task cannot move to another project."
    )

    @Argument(help: "Task ID or URL")
    var id: ResourceID

    @Option(name: .long, help: "Task name, unique within the project")
    var name: String?

    @OptionGroup var task: TaskOptions

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.TaskResponse {
        let input = Operations.UpdateTask.Input(
            path: .init(id: id.value),
            body: .json(.init(task: task.updatePayload(name: name)))
        )

        return try await client.updateTask(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.TaskResponse) -> String {
        "Updated task \(id)"
    }
}
