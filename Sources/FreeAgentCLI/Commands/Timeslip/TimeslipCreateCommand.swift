import ArgumentParser
import Foundation
import FreeAgentAPI

struct TimeslipCreateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a timeslip",
        discussion: "The timeslip belongs to the task's project."
    )

    @Option(name: .long, help: "Task ID or URL")
    var task: ResourceID

    @Option(name: .long, help: "Timeslip dated on (YYYY-MM-DD)")
    var datedOn: String

    @Option(name: .long, help: "Hours worked, e.g. 1.5 for 1:30 (default: 0)")
    var hours: Double?

    @Option(name: .long, help: "Comment for the timeslip")
    var comment: String?

    @OptionGroup var user: UserOptions

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.TimeslipResponse {
        let timeslipPayload = try await Components.Schemas.TimeslipCreatePayload(
            user: user.id(client: client),
            task: task.value,
            datedOn: datedOn,
            hours: hours,
            comment: comment
        )

        let input = Operations.CreateTimeslip.Input(
            body: .json(.init(timeslip: timeslipPayload))
        )

        return try await client.createTimeslip(input)
            .created.body.json
    }

    func success(for response: Components.Schemas.TimeslipResponse) -> String {
        "Created timeslip \(response.timeslip.url)"
    }
}
