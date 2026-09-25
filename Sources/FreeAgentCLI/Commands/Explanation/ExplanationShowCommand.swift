import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExplanationShowCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show bank transaction explanation details"
    )

    static let title = "Explanation"

    static let tables = [
        FieldTable<Components.Schemas.BankTransactionExplanation>("Attachments", items: { $0.attachments }) {
            Field("ID") { .id(url: $0.url) }
        }
    ]

    static var sections: [FieldSection<Components.Schemas.BankTransactionExplanation>] {
        FieldSection("Details") {
            Field("Type") { .text($0._type) }
            Field("Description") { .text($0.description) }
            Field("Detail") { .text($0.detail) }
            Field("Transaction Description") { .text($0.transactionDescription) }
            Field("Receipt Reference") { .text($0.receiptReference) }
            Field("Cheque Number") { .text($0.chequeNumber) }
            Field("Marked For Review") { .flag($0.markedForReview) }
            Field("Locked") { .flag($0.isLocked) }
            Field("Locked Reason") { .text($0.lockedReason) }
            Field("Rebill Type") { .text($0.rebillType) }
            Field("Rebill Factor") { .text($0.rebillFactor) }
            Field("Asset Life (Years)") { .text($0.assetLifeYears) }
        }
        FieldSection("Amounts") {
            Field("Gross Value") { .currency($0.grossValue, code: nil) }
            Field("Foreign Currency Value") { .currency($0.foreignCurrencyValue, code: nil) }
            Field("Transfer Value") { .currency($0.transferValue, code: nil) }
        }
        FieldSection("Sales Tax") {
            Field("Rate") { .percent($0.salesTaxRate) }
            Field("Value") { .currency($0.salesTaxValue, code: nil) }
            Field("Status") { .status($0.salesTaxStatus) }
            Field("Second Rate") { .percent($0.secondSalesTaxRate) }
            Field("Second Value") { .currency($0.secondSalesTaxValue, code: nil) }
            Field("Second Status") { .status($0.secondSalesTaxStatus) }
            Field("Manual Amount") { .currency($0.manualSalesTaxAmount, code: nil) }
            Field("EC Status") { .text($0.ecStatus) }
            Field("Place Of Supply") { .text($0.placeOfSupply) }
        }
        FieldSection("Dates") {
            Field("Dated On") { .date($0.datedOn) }
            Field("Updated") { .timestamp($0.updatedAt) }
        }
        FieldSection("IDs") {
            Field("Explanation") { .id(url: $0.url) }
            Field("Bank Transaction") { .id(url: $0.bankTransaction) }
            Field("Bank Account") { .id(url: $0.bankAccount) }
            Field("Category") { .id(url: $0.category) }
            Field("Paid Invoice") { .id(url: $0.paidInvoice) }
            Field("Paid Bill") { .id(url: $0.paidBill) }
            Field("Paid User") { .id(url: $0.paidUser) }
            Field("Project") { .id(url: $0.project) }
            Field("Property") { .id(url: $0.property) }
            Field("Contact") { .id(url: $0.directContact) }
            Field("Transfer Account") { .id(url: $0.transferBankAccount) }
            Field("Linked Transfer") { .id(url: $0.linkedTransferExplanation) }
            Field("Linked Account") { .id(url: $0.linkedTransferAccount) }
            Field("Stock Item") { .id(url: $0.stockItem) }
            Field("Capital Asset") { .id(url: $0.capitalAsset) }
            Field("Disposed Asset") { .id(url: $0.disposedAsset) }
        }
    }

    @Argument(help: "Explanation ID")
    var id: String

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.BankTransactionExplanationResponse {
        try await client.getASingleBankTransactionExplanation(.init(path: .init(id: id))).ok.body.json
    }

    func record(
        in response: Components.Schemas.BankTransactionExplanationResponse
    ) -> Components.Schemas.BankTransactionExplanation {
        response.bankTransactionExplanation
    }
}
