import ArgumentParser
import Foundation
import FreeAgentAPI

struct BankAccountListCommand: ListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List bank accounts"
    )

    static let noun = "bank accounts"

    static var columns: [Field<Components.Schemas.BankAccount>] {
        Field("ID") { .id(url: $0.url) }
        Field("Name") { .text($0.name) }
        Field("Bank") { .text($0.bankName) }
        Field("Type") { .text($0._type) }
        Field("Balance") { .currency($0.currentBalance, code: $0.currency) }
    }

    @Option(name: .long, help: "Filter by view (e.g. standard_bank_accounts)")
    var view: String?

    @OptionGroup var pagination: PaginationOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(
        client: Client,
        page: Int
    ) async throws -> (response: Components.Schemas.BankAccountListResponse, totalCount: Int?) {
        let ok = try await client.listBankAccounts(.init(query: .init(view: view, page: page, perPage: pagination.size))).ok

        return (try ok.body.json, ok.headers.xTotalCount)
    }

    func items(in response: Components.Schemas.BankAccountListResponse) -> [Components.Schemas.BankAccount] {
        response.bankAccounts
    }
}
