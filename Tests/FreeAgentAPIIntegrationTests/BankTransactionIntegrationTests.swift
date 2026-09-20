import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("bank_transactions")))
struct BankTransactionIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/bank_transactions returns a typed list")
    func listBankTransactions() async throws {
        let account = try #require(try await firstBankAccountURL())

        let transactions = try await client.listAllBankTransactionsUnderACertainBankAccount(
            .init(query: .init(bankAccount: account, view: "all"))
        ).ok.body.json.bankTransactions

        #expect(!transactions.isEmpty)

        let transaction = try #require(transactions.first)
        #expect(transaction.url.contains("/v2/bank_transactions/"))
        #expect(transaction.bankAccount == account)
        #expect(transaction.isManual != nil)
        #expect(transaction.matchingTransactionsCount != nil)
        #expect(transaction.uploadedAt != nil)
    }

    @Test("An explained transaction carries its explanations in full")
    func explainedTransactionCarriesNestedExplanations() async throws {
        let account = try #require(try await firstBankAccountURL())

        let transactions = try await client.listAllBankTransactionsUnderACertainBankAccount(
            .init(query: .init(bankAccount: account, view: "explained"))
        ).ok.body.json.bankTransactions

        let transaction = try #require(transactions.first)
        let explanation = try #require(transaction.bankTransactionExplanations?.first)

        #expect(explanation.url.contains("/v2/bank_transaction_explanations/"))
        #expect(explanation.bankTransaction == transaction.url)
        #expect(explanation._type != nil)
        #expect(explanation.grossValue != nil)
        #expect(explanation.attachments != nil)
    }

    @Test("GET /v2/bank_transactions/:id returns a typed bank transaction")
    func showBankTransaction() async throws {
        let account = try #require(try await firstBankAccountURL())

        let listed = try #require(
            try await client.listAllBankTransactionsUnderACertainBankAccount(
                .init(query: .init(bankAccount: account, view: "all"))
            ).ok.body.json.bankTransactions.first
        )
        let id = String(listed.url.split(separator: "/").last ?? "")

        let transaction = try await client.getASingleBankTransaction(.init(path: .init(id: id)))
            .ok.body.json.bankTransaction

        #expect(transaction.url == listed.url)
        #expect(transaction.amount == listed.amount)
        #expect(transaction.datedOn == listed.datedOn)
    }

    // MARK: Private

    private let client: Client

    private func firstBankAccountURL() async throws -> String? {
        try await client.listBankAccounts(.init())
            .ok.body.json.bankAccounts.first?.url
    }

}
