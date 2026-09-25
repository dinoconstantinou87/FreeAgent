import ArgumentParser
import Foundation
import FreeAgentAPI

struct BankAccountShowCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show bank account details"
    )

    static let title = "Bank Account"

    static var sections: [FieldSection<Components.Schemas.BankAccount>] {
        FieldSection("Details") {
            Field("Name") { .text($0.name) }
            Field("Bank") { .text($0.bankName) }
            Field("Type") { .text($0._type) }
            Field("Status") { .status($0.status) }
            Field("Currency") { .text($0.currency) }
            Field("Primary") { .flag($0.isPrimary) }
            Field("Personal") { .flag($0.isPersonal) }
            Field("Bank Feed") { .flag($0.bankFeedEnabled) }
            Field("Email") { .text($0.email) }
        }
        FieldSection("Account") {
            Field("Account Number") { .text($0.accountNumber) }
            Field("Sort Code") { .text($0.sortCode) }
            Field("Secondary Sort Code") { .text($0.secondarySortCode) }
            Field("IBAN") { .text($0.iban) }
            Field("BIC") { .text($0.bic) }
        }
        FieldSection("Balance") {
            Field("Current") { .currency($0.currentBalance, code: $0.currency) }
            Field("Opening") { .currency($0.openingBalance, code: $0.currency) }
        }
        FieldSection("Transactions") {
            Field("Total") { .number($0.totalCount) }
            Field("Unexplained") { .number($0.unexplainedTransactionCount) }
            Field("For Review") { .number($0.markedForReviewCount) }
            Field("Manually Added") { .number($0.manuallyAddedTransactionCount) }
            Field("Latest Activity") { .date($0.latestActivityDate) }
        }
        FieldSection("Dates") {
            Field("Created") { .timestamp($0.createdAt) }
            Field("Updated") { .timestamp($0.updatedAt) }
        }
        FieldSection("IDs") {
            Field("Bank Account") { .id(url: $0.url) }
        }
    }

    @Argument(help: "Bank account ID")
    var id: String

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.BankAccountResponse {
        try await client.showBankAccount(.init(path: .init(id: id))).ok.body.json
    }

    func record(in response: Components.Schemas.BankAccountResponse) -> Components.Schemas.BankAccount {
        response.bankAccount
    }
}
