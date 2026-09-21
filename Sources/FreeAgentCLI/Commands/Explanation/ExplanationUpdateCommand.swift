import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExplanationUpdateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update a bank transaction explanation",
        discussion: "Attachments are managed with 'freeagent explanation attachment'."
    )

    @Argument(help: "Explanation ID")
    var id: String

    @Option(name: .long, help: "Category URL")
    var category: String?

    @Option(name: .long, help: "Description")
    var description: String?

    @Option(name: .long, parsing: .unconditional, help: "Gross value")
    var grossValue: String?

    @Option(name: .long, help: "Bill URL to mark as paid")
    var paidBill: String?

    @Option(name: .long, help: "User URL for DLA/salary payment")
    var paidUser: String?

    @Option(name: .long, help: "Sales tax rate, e.g. 20.0 or 0.0 to zero-rate (e.g. EU purchases, gift vouchers)")
    var salesTaxRate: String?

    @Option(name: .long, help: "Manual sales tax amount override (e.g. 0.0)")
    var manualSalesTax: String?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    func run(client: Client) async throws -> Components.Schemas.BankTransactionExplanationResponse? {
        let payload = Components.Schemas.BankTransactionExplanationUpdatePayload(
            category: category,
            description: description,
            grossValue: grossValue,
            paidBill: paidBill,
            paidUser: paidUser,
            salesTaxRate: salesTaxRate,
            manualSalesTaxAmount: manualSalesTax
        )

        let input = Operations.UpdateABankTransactionExplanation.Input(
            path: .init(id: id),
            body: .json(.init(bankTransactionExplanation: payload))
        )

        return try await client.updateABankTransactionExplanation(input)
            .ok.body.json
    }
}
