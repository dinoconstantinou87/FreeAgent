import ArgumentParser
import Foundation
import FreeAgentAPI

struct VatReturnShowCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show VAT return details"
    )

    static let title = "VAT Return"

    static let tables = [
        FieldTable<Components.Schemas.VatReturn>("Payments", items: { $0.payments }) {
            Field("Payment") { .text($0.label) }
            Field("Due On") { .date($0.dueOn) }
            Field("Amount Due") { .currency($0.amountDue?.description, code: nil) }
            Field("Status") { .status($0.status) }
        },
        FieldTable("Breakdown", items: { $0.breakdown?.rows }) {
            Field("Box") { .number($0.boxNumber) }
            Field("Description") { .text($0.title) }
            Field("Value") { .currency($0.value, code: nil) }
        },
    ]

    static var sections: [FieldSection<Components.Schemas.VatReturn>] {
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
    }

    @Argument(help: "Period end date, e.g. 2025-10-31")
    var periodEndsOn: String

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.VatReturnResponse {
        try await client.showVatReturn(.init(path: .init(periodEndsOn: periodEndsOn))).ok.body.json
    }

    func record(in response: Components.Schemas.VatReturnResponse) -> Components.Schemas.VatReturn {
        response.vatReturn
    }
}
