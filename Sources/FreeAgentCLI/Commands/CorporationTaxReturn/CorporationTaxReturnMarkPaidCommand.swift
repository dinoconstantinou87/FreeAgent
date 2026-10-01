import ArgumentParser
import Foundation
import FreeAgentAPI

struct CorporationTaxReturnMarkPaidCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-paid",
        abstract: "Mark corporation tax return as paid"
    )

    @Argument(help: "Period end date, e.g. 2025-12-31")
    var periodEndsOn: String

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.CorporationTaxReturnResponse {
        let input = Operations.MarkCorporationTaxReturnAsPaid.Input(
            path: .init(periodEndsOn: periodEndsOn)
        )

        return try await client.markCorporationTaxReturnAsPaid(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.CorporationTaxReturnResponse) -> String {
        "Marked corporation tax return \(periodEndsOn) as paid"
    }
}
