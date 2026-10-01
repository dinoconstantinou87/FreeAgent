import ArgumentParser
import Foundation
import FreeAgentAPI

struct CorporationTaxReturnListCommand: PaginatedListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List corporation tax returns"
    )

    static let noun = "corporation tax returns"

    static var columns: [Field<Components.Schemas.CorporationTaxReturn>] {
        Field("Period Starts") { .date($0.periodStartsOn) }
        Field("Period Ends") { .date($0.periodEndsOn) }
        Field("Filing Due") { .date($0.filingDueOn) }
        Field("Filing Status") { .status($0.filingStatus) }
        Field("Payment Due") { .date($0.paymentDueOn) }
        Field("Amount Due") { .currency($0.amountDue, code: nil) }
        Field("Payment Status") { .status($0.paymentStatus) }
    }

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.CorporationTaxReturnListResponse {
        try await client.listCorporationTaxReturns(.init()).ok.body.json
    }

    func items(
        in response: Components.Schemas.CorporationTaxReturnListResponse
    ) -> [Components.Schemas.CorporationTaxReturn] {
        response.corporationTaxReturns
    }
}
