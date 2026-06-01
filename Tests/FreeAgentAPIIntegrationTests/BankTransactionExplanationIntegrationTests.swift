import Foundation
import OpenAPIRuntime
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("bank_transaction_explanations")))
struct BankTransactionExplanationIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("POST /v2/bank_transaction_explanations zero-rates VAT when sales_tax_rate is 0.0")
    func zeroRatedExplanationOverridesStandardRatedCategory() async throws {
        let transaction = try await firstUnexplainedTransaction()

        let payload = Components.Schemas.BankTransactionExplanationCreatePayload(
            bankAccount: transaction.bankAccount,
            bankTransaction: transaction.url,
            category: standardRatedCategoryURL(forMoneyIn: transaction.isMoneyIn),
            datedOn: transaction.datedOn,
            description: "Integration test zero-rated explanation",
            grossValue: transaction.grossValue,
            salesTaxRate: "0.0"
        )
        let createInput = Operations.CreateABankTransactionExplanation.Input(
            body: .json(.init(bankTransactionExplanation: payload))
        )

        let created = try await client.createABankTransactionExplanation(createInput)
            .created.body.json.bankTransactionExplanation

        #expect(created.url.contains("/v2/bank_transaction_explanations/"))
        #expect(created.grossValue == transaction.grossValue)
        #expect(created.salesTaxRate == "0.0")
        #expect(created.salesTaxValue == "0.0")

        try await delete(created.url)
    }

    // MARK: Private

    private struct UnexplainedTransaction {
        let url: String
        let bankAccount: String
        let datedOn: String
        let grossValue: String

        var isMoneyIn: Bool {
            !grossValue.hasPrefix("-")
        }
    }

    private let client: Client
    private let salesCategoryCode = "001"
    private let accommodationCategoryCode = "285"

    private func standardRatedCategoryURL(forMoneyIn moneyIn: Bool) -> String {
        let code = moneyIn ? salesCategoryCode : accommodationCategoryCode
        return Environment.sandbox.baseURL.appending(path: "v2/categories/\(code)").absoluteString
    }

    private func firstUnexplainedTransaction() async throws -> UnexplainedTransaction {
        let account = try #require(try await firstBankAccountURL())

        let input = Operations.ListAllBankTransactionsUnderACertainBankAccount.Input(
            query: .init(bankAccount: account, view: "unexplained", perPage: 1)
        )
        let body = try await client.listAllBankTransactionsUnderACertainBankAccount(input)
            .ok.body.json.additionalProperties.value

        let transactions = try #require(body["bank_transactions"] as? [Any])
        let transaction = try #require(transactions.first as? [String: Any])

        return try UnexplainedTransaction(
            url: #require(transaction["url"] as? String),
            bankAccount: account,
            datedOn: #require(transaction["dated_on"] as? String),
            grossValue: #require(transaction["unexplained_amount"] as? String)
        )
    }

    private func firstBankAccountURL() async throws -> String? {
        let body = try await client.listBankAccounts(.init())
            .ok.body.json.additionalProperties.value
        let accounts = try #require(body["bank_accounts"] as? [Any])
        let account = try #require(accounts.first as? [String: Any])
        return account["url"] as? String
    }

    private func delete(_ url: String) async throws {
        let id = String(url.split(separator: "/").last ?? "")
        let input = Operations.DeleteABankTransactionExplanation.Input(path: .init(id: id))
        _ = try await client.deleteABankTransactionExplanation(input)
    }

}
