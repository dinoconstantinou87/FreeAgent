import ArgumentParser
import Foundation
import FreeAgentAPI

struct SelfAssessmentReturnListCommand: PaginatedListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List self assessment returns"
    )

    static let noun = "self assessment returns"

    static var columns: [Field<Components.Schemas.SelfAssessmentReturn>] {
        Field("Period Starts") { .date($0.periodStartsOn) }
        Field("Period Ends") { .date($0.periodEndsOn) }
        Field("Filing Due") { .date($0.filingDueOn) }
        Field("Filing Status") { .status($0.filingStatus) }
        Field("Payment") { .text($0.payments?.first?.label) }
        Field("Amount Due") { .currency($0.payments?.first?.amountDue?.description, code: nil) }
        Field("Payment Status") { .status($0.payments?.first?.status) }
    }

    @OptionGroup var user: UserOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.SelfAssessmentReturnListResponse {
        let userId = try await user.id(client: client)

        return try await client.listSelfAssessmentReturns(.init(path: .init(userId: userId))).ok.body.json
    }

    func items(
        in response: Components.Schemas.SelfAssessmentReturnListResponse
    ) -> [Components.Schemas.SelfAssessmentReturn] {
        response.selfAssessmentReturns
    }
}
