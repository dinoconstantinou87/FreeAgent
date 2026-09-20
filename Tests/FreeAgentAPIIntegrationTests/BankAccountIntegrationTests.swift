import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("bank_accounts")))
struct BankAccountIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/bank_accounts returns a typed list")
    func listBankAccounts() async throws {
        let accounts = try await client.listBankAccounts(.init())
            .ok.body.json.bankAccounts

        #expect(!accounts.isEmpty)

        let account = try #require(accounts.first)
        #expect(account.url.contains("/v2/bank_accounts/"))
        #expect(account._type == "StandardBankAccount")
        #expect(account.currency == "GBP")
        #expect(try #require(account.createdAt) <= Date())
    }

    @Test("GET /v2/bank_accounts/:id returns a typed bank account")
    func showBankAccount() async throws {
        let listed = try #require(
            try await client.listBankAccounts(.init()).ok.body.json.bankAccounts.first
        )
        let id = String(listed.url.split(separator: "/").last ?? "")

        let account = try await client.showBankAccount(.init(path: .init(id: id)))
            .ok.body.json.bankAccount

        #expect(account.url == listed.url)
        #expect(account.name == listed.name)
        #expect(account.bankGuessEnabled != nil)
    }

    // MARK: Private

    private let client: Client

}
