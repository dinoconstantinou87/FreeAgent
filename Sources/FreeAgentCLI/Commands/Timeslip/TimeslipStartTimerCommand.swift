import ArgumentParser
import Foundation
import FreeAgentAPI

struct TimeslipStartTimerCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "start-timer",
        abstract: "Start a timer on a timeslip",
        discussion: "The timer counts on from the timeslip's hours. Starting a running timer leaves it running."
    )

    @Argument(help: "Timeslip ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.TimeslipResponse {
        let input = Operations.StartTimeslipTimer.Input(
            path: .init(id: id.value)
        )

        return try await client.startTimeslipTimer(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.TimeslipResponse) -> String {
        "Started the timer on timeslip \(id)"
    }
}
