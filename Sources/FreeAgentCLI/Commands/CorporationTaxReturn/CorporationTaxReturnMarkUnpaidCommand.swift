import ArgumentParser
import Foundation
import FreeAgentAPI

struct CorporationTaxReturnMarkUnpaidCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-unpaid",
        abstract: "Mark corporation tax return as unpaid"
    )

    @Argument(help: "Period end date, e.g. 2025-12-31")
    var periodEndsOn: String

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.CorporationTaxReturnResponse {
        let input = Operations.MarkCorporationTaxReturnAsUnpaid.Input(
            path: .init(periodEndsOn: periodEndsOn)
        )

        return try await client.markCorporationTaxReturnAsUnpaid(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.CorporationTaxReturnResponse) -> String {
        "Marked corporation tax return \(periodEndsOn) as unpaid"
    }
}
