import ArgumentParser
import Foundation
import FreeAgentAPI

struct BankAccountListCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List bank accounts"
    )

    @Option(name: .long, help: "Filter by view (e.g. standard_bank_accounts)")
    var view: String?

    @Option(name: .long, help: "Maximum number of bank accounts to fetch")
    var limit = ListLimit.default

    func run(client: Client) async throws -> Components.Schemas.BankAccountListResponse? {
        let accounts = try await Paginator.collect(limit: limit.value) { page, perPage in
            let ok = try await client.listBankAccounts(.init(query: .init(view: view, page: page, perPage: perPage))).ok

            return (try ok.body.json.bankAccounts, ok.headers.xTotalCount)
        }

        return .init(bankAccounts: accounts)
    }
}
