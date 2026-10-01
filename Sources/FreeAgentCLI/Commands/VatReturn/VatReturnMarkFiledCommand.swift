import ArgumentParser
import Foundation
import FreeAgentAPI

struct VatReturnMarkFiledCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-filed",
        abstract: "Mark VAT return as filed"
    )

    @Argument(help: "Period end date, e.g. 2025-10-31")
    var periodEndsOn: String

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.VatReturnResponse {
        let input = Operations.MarkVatReturnAsFiled.Input(
            path: .init(periodEndsOn: periodEndsOn)
        )

        return try await client.markVatReturnAsFiled(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.VatReturnResponse) -> String {
        "Marked VAT return \(periodEndsOn) as filed"
    }
}
