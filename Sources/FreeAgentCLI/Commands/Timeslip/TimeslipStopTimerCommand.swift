import ArgumentParser
import Foundation
import FreeAgentAPI

struct TimeslipStopTimerCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "stop-timer",
        abstract: "Stop the timer on a timeslip",
        discussion: "FreeAgent adds the whole minutes the timer ran to the hours it started with."
    )

    @Argument(help: "Timeslip ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.TimeslipResponse {
        let input = Operations.StopTimeslipTimer.Input(
            path: .init(id: id.value)
        )

        return try await client.stopTimeslipTimer(input)
            .ok.body.json
    }

    func success(for response: Components.Schemas.TimeslipResponse) -> String {
        guard let hours = FieldValue.hours(response.timeslip.hours).formatted() else {
            return "Stopped the timer on timeslip \(id)"
        }

        return "Stopped the timer on timeslip \(id) at \(hours)"
    }
}
