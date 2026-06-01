import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExplanationCreateCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a bank transaction explanation"
    )

    @Option(name: .long, help: "Bank transaction URL (e.g. https://api.freeagent.com/v2/bank_transactions/123)")
    var bankTransaction: String

    @Option(name: .long, help: "Bank account URL (e.g. https://api.freeagent.com/v2/bank_accounts/123)")
    var bankAccount: String

    @Option(name: .long, help: "Category URL (e.g. https://api.freeagent.com/v2/categories/285)")
    var category: String?

    @Option(name: .long, help: "Date of the explanation (YYYY-MM-DD)")
    var datedOn: String

    @Option(name: .long, help: "Description of the explanation")
    var description: String

    @Option(name: .long, help: "Gross value (e.g. -730.0)")
    var grossValue: String

    @Option(name: .long, help: "Bill URL to mark as paid (e.g. https://api.freeagent.com/v2/bills/123)")
    var paidBill: String?

    @Option(name: .long, help: "Invoice URL to mark as paid (e.g. https://api.freeagent.com/v2/invoices/123)")
    var paidInvoice: String?

    @Option(name: .long, help: "User URL for DLA/salary payment (e.g. https://api.freeagent.com/v2/users/1)")
    var paidUser: String?

    @Option(name: .long, help: "Project URL (optional)")
    var project: String?

    @Option(name: .long, help: "Rebill type (e.g. markup, price)")
    var rebillType: String?

    @Option(name: .long, help: "Rebill factor")
    var rebillFactor: String?

    @Option(name: .long, help: "Sales tax rate, e.g. 20.0 or 0.0 to zero-rate (e.g. EU purchases, gift vouchers)")
    var salesTaxRate: String?

    @Option(name: .long, help: "Manual sales tax amount override (e.g. 0.0)")
    var manualSalesTax: String?

    func run(client: Client) async throws -> Components.Schemas.BankTransactionExplanationResponse? {
        let payload = Components.Schemas.BankTransactionExplanationCreatePayload(
            bankAccount: bankAccount,
            bankTransaction: bankTransaction,
            category: category,
            datedOn: datedOn,
            description: description,
            grossValue: grossValue,
            paidBill: paidBill,
            paidInvoice: paidInvoice,
            paidUser: paidUser,
            project: project,
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
}
