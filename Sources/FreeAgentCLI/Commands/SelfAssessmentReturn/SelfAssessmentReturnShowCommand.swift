import ArgumentParser
import Foundation
import FreeAgentAPI

struct SelfAssessmentReturnShowCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show self assessment return details"
    )

    static let title = "Self Assessment Return"

    static let tables = [
        FieldTable<Components.Schemas.SelfAssessmentReturn>("Payments", items: { $0.payments }) {
            Field("Payment") { .text($0.label) }
            Field("Due On") { .date($0.dueOn) }
            Field("Amount Due") { .currency($0.amountDue?.description, code: nil) }
            Field("Status") { .status($0.status) }
        }
    ]

    static var sections: [FieldSection<Components.Schemas.SelfAssessmentReturn>] {
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

    @Argument(help: "Period end date, e.g. 2025-04-05")
    var periodEndsOn: String

    @OptionGroup var user: UserOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.SelfAssessmentReturnResponse {
        let userId = try await user.id(client: client)

        return try await client.showSelfAssessmentReturn(
            .init(path: .init(userId: userId, periodEndsOn: periodEndsOn))
        ).ok.body.json
    }

    func record(
        in response: Components.Schemas.SelfAssessmentReturnResponse
    ) -> Components.Schemas.SelfAssessmentReturn {
        response.selfAssessmentReturn
    }
}
