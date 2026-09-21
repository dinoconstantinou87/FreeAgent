import Foundation
import OpenAPIRuntime
import Testing

@testable import FreeAgentAPI

@Suite(.serialized, .enabled(if: IntegrationTest.isModelEnabled("bank_transaction_explanations")))
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

    @Test("GET /v2/bank_transaction_explanations returns a typed list")
    func listExplanations() async throws {
        let transaction = try await firstUnexplainedTransaction()

        let payload = Components.Schemas.BankTransactionExplanationCreatePayload(
            bankAccount: transaction.bankAccount,
            bankTransaction: transaction.url,
            category: standardRatedCategoryURL(forMoneyIn: transaction.isMoneyIn),
            datedOn: transaction.datedOn,
            description: "Integration test listed explanation",
            grossValue: transaction.grossValue
        )
        let createInput = Operations.CreateABankTransactionExplanation.Input(
            body: .json(.init(bankTransactionExplanation: payload))
        )
        let created = try await client.createABankTransactionExplanation(createInput)
            .created.body.json.bankTransactionExplanation

        let listInput = Operations.ListAllBankTransactionExplanations.Input(
            query: .init(bankAccount: transaction.bankAccount)
        )
        let explanations = try await client.listAllBankTransactionExplanations(listInput)
            .ok.body.json.bankTransactionExplanations

        let listed = try #require(explanations.first { $0.url == created.url })

        #expect(listed.url.contains("/v2/bank_transaction_explanations/"))
        #expect(listed.datedOn == transaction.datedOn)
        #expect(listed.grossValue == transaction.grossValue)
        #expect(listed.bankTransaction == transaction.url)
        #expect(listed.isDeletable == true)
        #expect(listed.updatedAt != nil)

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
        let transaction = try #require(
            try await client.listAllBankTransactionsUnderACertainBankAccount(input)
                .ok.body.json.bankTransactions.first
        )

        return try UnexplainedTransaction(
            url: transaction.url,
            bankAccount: account,
            datedOn: #require(transaction.datedOn),
            grossValue: #require(transaction.unexplainedAmount)
        )
    }

    private func firstBankAccountURL() async throws -> String? {
        try await client.listBankAccounts(.init())
            .ok.body.json.bankAccounts.first?.url
    }

    private func delete(_ url: String) async throws {
        let id = String(url.split(separator: "/").last ?? "")
        let input = Operations.DeleteABankTransactionExplanation.Input(path: .init(id: id))
        _ = try await client.deleteABankTransactionExplanation(input)
    }

}
