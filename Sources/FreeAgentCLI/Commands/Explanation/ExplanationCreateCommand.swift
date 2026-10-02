import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExplanationCreateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a bank transaction explanation"
    )

    @Option(name: .long, help: "Bank transaction ID or URL")
    var bankTransaction: ResourceID

    @Option(name: .long, help: "Bank account ID or URL")
    var bankAccount: ResourceID

    @Option(name: .long, help: "Category ID or URL, e.g. 285")
    var category: ResourceID?

    @Option(name: .long, help: "Date of the explanation (YYYY-MM-DD)")
    var datedOn: String

    @Option(name: .long, help: "Description of the explanation")
    var description: String

    @Option(name: .long, parsing: .unconditional, help: "Gross value (e.g. -730.0)")
    var grossValue: String

    @Option(name: .long, help: "Bill ID or URL to mark as paid")
    var paidBill: ResourceID?

    @Option(name: .long, help: "Invoice ID or URL to mark as paid")
    var paidInvoice: ResourceID?

    @Option(name: .long, help: "User ID or URL for DLA/salary payment")
    var paidUser: ResourceID?

    @Option(name: .long, help: "Project ID or URL")
    var project: ResourceID?

    @Option(name: .long, help: "Rebill type (e.g. markup, price)")
    var rebillType: String?

    @Option(name: .long, help: "Rebill factor")
    var rebillFactor: String?

    @Option(name: .long, help: "Sales tax rate, e.g. 20.0 or 0.0 to zero-rate (e.g. EU purchases, gift vouchers)")
    var salesTaxRate: String?

    @Option(name: .long, help: "Manual sales tax amount override (e.g. 0.0)")
    var manualSalesTax: String?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.BankTransactionExplanationResponse {
        let payload = Components.Schemas.BankTransactionExplanationCreatePayload(
            bankAccount: bankAccount.value,
            bankTransaction: bankTransaction.value,
            category: category?.value,
            datedOn: datedOn,
            description: description,
            grossValue: grossValue,
            paidBill: paidBill?.value,
            paidInvoice: paidInvoice?.value,
            paidUser: paidUser?.value,
            project: project?.value,
            rebillFactor: rebillFactor,
            rebillType: rebillType,
            salesTaxRate: salesTaxRate,
            manualSalesTaxAmount: manualSalesTax
        )

        let input = Operations.CreateABankTransactionExplanation.Input(
            body: .json(.init(bankTransactionExplanation: payload))
        )

        return try await client.createABankTransactionExplanation(input)
            .created.body.json
    }

    func success(for response: Components.Schemas.BankTransactionExplanationResponse) -> String {
        "Created explanation \(response.bankTransactionExplanation.url)"
    }
}
