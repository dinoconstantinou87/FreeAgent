import ArgumentParser
import Foundation
import FreeAgentAPI

struct TaskCreateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a task",
        discussion: "The billing rate and period default to the project's, the task is billable and Active unless told otherwise, and its currency is always the project's."
    )

    @Option(name: .long, help: "Project ID or URL")
    var project: ResourceID

    @Option(name: .long, help: "Task name, unique within the project")
    var name: String

    @OptionGroup var task: TaskOptions

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.TaskResponse {
        let input = Operations.CreateTask.Input(
            query: .init(project: project.value),
            body: .json(.init(task: task.createPayload(name: name)))
        )

        return try await client.createTask(input)
            .created.body.json
    }

    func success(for response: Components.Schemas.TaskResponse) -> String {
        "Created task \(response.task.url)"
    }
}
