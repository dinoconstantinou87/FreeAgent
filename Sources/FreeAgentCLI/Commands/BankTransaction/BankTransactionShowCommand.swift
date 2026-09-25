import ArgumentParser
import Foundation
import FreeAgentAPI

struct BankTransactionShowCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show bank transaction details"
    )

    static let title = "Bank Transaction"

    static let sections: [FieldSection<Components.Schemas.BankTransaction>] = [
        FieldSection("Details", fields: [
            Field("Description") { .text($0.description) },
            Field("Full Description") { .text($0.fullDescription) },
            Field("Manual") { .flag($0.isManual) },
        ]),
        FieldSection("Amounts", fields: [
            Field("Amount") { .currency($0.amount, code: nil) },
            Field("Unexplained") { .currency($0.unexplainedAmount, code: nil) },
        ]),
        FieldSection("Dates", fields: [
            Field("Dated On") { .date($0.datedOn) },
            Field("Uploaded") { .timestamp($0.uploadedAt) },
            Field("Created") { .timestamp($0.createdAt) },
            Field("Updated") { .timestamp($0.updatedAt) },
        ]),
        FieldSection("IDs", fields: [
            Field("Bank Transaction") { .id(url: $0.url) },
            Field("Bank Account") { .id(url: $0.bankAccount) },
            Field("Transaction") { .text($0.transactionId) },
        ]),
    ]

    static let tables = [
        FieldTable<Components.Schemas.BankTransaction>("Explanations", columns: ExplanationListCommand.columns) {
            $0.bankTransactionExplanations
        }
    ]

    @Argument(help: "Bank transaction ID")
    var id: String

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.BankTransactionResponse {
        try await client.getASingleBankTransaction(.init(path: .init(id: id))).ok.body.json
    }

    func record(in response: Components.Schemas.BankTransactionResponse) -> Components.Schemas.BankTransaction {
        response.bankTransaction
    }
}
