import ArgumentParser
import Foundation
import FreeAgentAPI

struct CorporationTaxReturnShowCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show corporation tax return details"
    )

    static let title = "Corporation Tax Return"

    static var sections: [FieldSection<Components.Schemas.CorporationTaxReturn>] {
        FieldSection("Period") {
            Field("Starts") { .date($0.periodStartsOn) }
            Field("Ends") { .date($0.periodEndsOn) }
        }
        FieldSection("Filing") {
            Field("Status") { .status($0.filingStatus) }
            Field("Due") { .date($0.filingDueOn) }
            Field("Filed") { .timestamp($0.filedAt) }
            Field("Reference") { .text($0.filedReference) }
        }
        FieldSection("Payment") {
            Field("Amount Due") { .currency($0.amountDue, code: nil) }
            Field("Due") { .date($0.paymentDueOn) }
            Field("Status") { .status($0.paymentStatus) }
        }
    }

    @Argument(help: "Period end date, e.g. 2025-12-31")
    var periodEndsOn: String

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.CorporationTaxReturnResponse {
        try await client.showCorporationTaxReturn(.init(path: .init(periodEndsOn: periodEndsOn))).ok.body.json
    }

    func record(
        in response: Components.Schemas.CorporationTaxReturnResponse
    ) -> Components.Schemas.CorporationTaxReturn {
        response.corporationTaxReturn
    }
}
