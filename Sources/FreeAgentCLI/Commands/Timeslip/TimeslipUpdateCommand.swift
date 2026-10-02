import ArgumentParser
import Foundation
import FreeAgentAPI

struct TimeslipUpdateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update a timeslip",
        discussion: "Changing the task moves the timeslip to that task's project."
    )

    @Argument(help: "Timeslip ID or URL")
    var id: ResourceID

    @Option(name: .long, help: "Task ID or URL")
    var task: ResourceID?

    @Option(name: .long, help: "User ID or URL")
    var user: ResourceID?

    @Option(name: .long, help: "Timeslip dated on (YYYY-MM-DD)")
    var datedOn: String?

    @Option(name: .long, help: "Hours worked, e.g. 1.5 for 1:30 - a running timer replaces this when it stops")
    var hours: Double?

    @Option(name: .long, help: "Comment for the timeslip, or an empty string to remove it")
    var comment: String?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.TimeslipResponse {
        let timeslipPayload = Components.Schemas.TimeslipUpdatePayload(
            user: user?.value,
            task: task?.value,
            datedOn: datedOn,
            hours: hours,
            comment: comment
        )

        let input = Operations.UpdateTimeslip.Input(
            path: .init(id: id.value),
            body: .json(.init(timeslip: timeslipPayload))
        )

        return try await client.updateTimeslip(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.TimeslipResponse) -> String {
        "Updated timeslip \(id)"
    }
}
