import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExplanationUpdateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update a bank transaction explanation",
        discussion: "Attachments are managed with 'freeagent explanation attachment'."
    )

    @Argument(help: "Explanation ID or URL")
    var id: ResourceID

    @Option(name: .long, help: "Category ID or URL, e.g. 285")
    var category: ResourceID?

    @Option(name: .long, help: "Description")
    var description: String?

    @Option(name: .long, parsing: .unconditional, help: "Gross value")
    var grossValue: String?

    @Option(name: .long, help: "Bill ID or URL to mark as paid")
    var paidBill: ResourceID?

    @Option(name: .long, help: "User ID or URL for DLA/salary payment")
    var paidUser: ResourceID?

    @Option(name: .long, help: "Sales tax rate, e.g. 20.0 or 0.0 to zero-rate (e.g. EU purchases, gift vouchers)")
    var salesTaxRate: String?

    @Option(name: .long, help: "Manual sales tax amount override (e.g. 0.0)")
    var manualSalesTax: String?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.BankTransactionExplanationResponse {
        let payload = Components.Schemas.BankTransactionExplanationUpdatePayload(
            category: category?.value,
            description: description,
            grossValue: grossValue,
            paidBill: paidBill?.value,
            paidUser: paidUser?.value,
            salesTaxRate: salesTaxRate,
            manualSalesTaxAmount: manualSalesTax
        )

        let input = Operations.UpdateABankTransactionExplanation.Input(
            path: .init(id: id.value),
            body: .json(.init(bankTransactionExplanation: payload))
        )

        return try await client.updateABankTransactionExplanation(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.BankTransactionExplanationResponse) -> String {
        "Updated explanation \(id)"
    }
}
