import ArgumentParser
import Foundation
import FreeAgentAPI

struct VatReturnMarkPaidCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "mark-paid",
        abstract: "Mark VAT return payment as paid"
    )

    @Argument(help: "Period end date, e.g. 2025-10-31")
    var periodEndsOn: String

    @Option(name: .long, help: "Due date of the payment, e.g. 2025-12-07")
    var paymentDate: String

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.VatReturnResponse {
        let input = Operations.MarkVatReturnPaymentAsPaid.Input(
            path: .init(periodEndsOn: periodEndsOn, paymentDate: paymentDate)
        )

        return try await client.markVatReturnPaymentAsPaid(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.VatReturnResponse) -> String {
        "Marked payment \(paymentDate) on VAT return \(periodEndsOn) as paid"
    }
}
