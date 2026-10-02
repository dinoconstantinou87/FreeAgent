import ArgumentParser
import Foundation
import FreeAgentAPI

struct EstimateMarkRejectedCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-rejected",
        abstract: "Mark estimate as rejected"
    )

    @Argument(help: "Estimate ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.EstimateResponse {
        let input = Operations.MarkEstimateAsRejected.Input(
            path: .init(id: id.value)
        )

        return try await client.markEstimateAsRejected(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.EstimateResponse) -> String {
        "Marked estimate \(id) as rejected"
    }
}
