import ArgumentParser
import Foundation
import FreeAgentAPI

struct EstimateDuplicateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "duplicate",
        abstract: "Duplicate an estimate as a new draft"
    )

    @Argument(help: "Estimate ID or URL")
    var id: ResourceID

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.EstimateResponse {
        let input = Operations.DuplicateEstimate.Input(
            path: .init(id: id.value)
        )

        return try await client.duplicateEstimate(input)
            .ok.body.json
    }

    func success(for response: Components.Schemas.EstimateResponse) -> String {
        "Duplicated estimate \(id) as \(response.estimate.url)"
    }
}
