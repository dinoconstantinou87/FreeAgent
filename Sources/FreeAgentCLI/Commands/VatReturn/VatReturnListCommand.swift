import ArgumentParser
import Foundation
import FreeAgentAPI

struct VatReturnListCommand: PaginatedListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List VAT returns"
    )

    static let noun = "VAT returns"

    static var columns: [Field<Components.Schemas.VatReturn>] {
        Field("Period Starts") { .date($0.periodStartsOn) }
        Field("Period Ends") { .date($0.periodEndsOn) }
        Field("Filing Due") { .date($0.filingDueOn) }
        Field("Filing Status") { .status($0.filingStatus) }
        Field("Payment") { .text($0.payments?.first?.label) }
        Field("Amount Due") { .currency($0.payments?.first?.amountDue?.description, code: nil) }
        Field("Payment Status") { .status($0.payments?.first?.status) }
    }

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.VatReturnListResponse {
        try await client.listVatReturns(.init()).ok.body.json
    }

    func items(in response: Components.Schemas.VatReturnListResponse) -> [Components.Schemas.VatReturn] {
        response.vatReturns
    }
}
