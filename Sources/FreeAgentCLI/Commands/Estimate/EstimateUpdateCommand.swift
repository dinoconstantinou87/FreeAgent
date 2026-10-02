import ArgumentParser
import Foundation
import FreeAgentAPI

struct EstimateUpdateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update an existing estimate"
    )

    @Argument(help: "Estimate ID or URL")
    var id: ResourceID

    @Option(name: .long, help: "Estimate dated on (YYYY-MM-DD)")
    var datedOn: String?

    @Option(name: .long, help: "Estimate type")
    var estimateType: Components.Schemas.EstimateType?

    @Option(name: .long, help: "Reference")
    var reference: String?

    @Option(name: .long, help: "Notes for the estimate")
    var notes: String?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.EstimateResponse {
        let estimatePayload = Components.Schemas.EstimateUpdatePayload(
            datedOn: datedOn,
            estimateType: estimateType,
            reference: reference,
            notes: notes
        )

        let input = Operations.UpdateEstimate.Input(
            path: .init(id: id.value),
            body: .json(.init(estimate: estimatePayload))
        )

        return try await client.updateEstimate(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.EstimateResponse) -> String {
        "Updated estimate \(id)"
    }
}
