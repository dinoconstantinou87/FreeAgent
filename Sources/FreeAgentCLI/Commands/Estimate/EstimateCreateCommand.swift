import ArgumentParser
import Foundation
import FreeAgentAPI

struct EstimateCreateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a draft estimate"
    )

    @Option(name: .long, help: "Contact ID or URL")
    var contact: ResourceID

    @Option(name: .long, help: "Estimate dated on (YYYY-MM-DD)")
    var datedOn: String

    @Option(name: .long, help: "Estimate type")
    var estimateType = Components.Schemas.EstimateType.estimate

    @Option(name: .long, help: "Reference (default: the next after the latest estimate's)")
    var reference: String?

    @Option(name: .long, help: "Project ID or URL")
    var project: ResourceID?

    @Option(name: .long, help: "Currency")
    var currency: Components.Schemas.Currency?

    @Option(name: .long, help: "Notes for the estimate")
    var notes: String?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.EstimateResponse {
        let estimatePayload = Components.Schemas.EstimateCreatePayload(
            contact: contact.value,
            project: project?.value,
            datedOn: datedOn,
            estimateType: estimateType,
            status: "Draft",
            reference: reference,
            currency: currency,
            notes: notes
        )

        let input = Operations.CreateEstimate.Input(
            body: .json(.init(estimate: estimatePayload))
        )

        return try await client.createEstimate(input)
            .created.body.json
    }

    func success(for response: Components.Schemas.EstimateResponse) -> String {
        "Created estimate \(response.estimate.url)"
    }
}
