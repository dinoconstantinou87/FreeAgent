import ArgumentParser
import Foundation
import FreeAgentAPI

struct SelfAssessmentReturnMarkUnpaidCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-unpaid",
        abstract: "Mark self assessment return payment as unpaid"
    )

    @Argument(help: "Period end date, e.g. 2025-04-05")
    var periodEndsOn: String

    @Option(name: .long, help: "Due date of the payment, e.g. 2026-01-31")
    var paymentDate: String

    @OptionGroup var user: UserOptions

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.SelfAssessmentReturnResponse {
        let userId = try await user.id(client: client)
        let input = Operations.MarkSelfAssessmentReturnPaymentAsUnpaid.Input(
            path: .init(userId: userId, periodEndsOn: periodEndsOn, paymentDate: paymentDate)
        )

        return try await client.markSelfAssessmentReturnPaymentAsUnpaid(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.SelfAssessmentReturnResponse) -> String {
        "Marked payment \(paymentDate) on self assessment return \(periodEndsOn) as unpaid"
    }
}
