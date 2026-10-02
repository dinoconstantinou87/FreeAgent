import ArgumentParser
import Foundation
import FreeAgentAPI

struct EstimateMarkSentCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-sent",
        abstract: "Mark estimate as sent"
    )

    @Argument(help: "Estimate ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.EstimateResponse {
        let input = Operations.MarkEstimateAsSent.Input(
            path: .init(id: id.value)
        )

        return try await client.markEstimateAsSent(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.EstimateResponse) -> String {
        "Marked estimate \(id) as sent"
    }
}
