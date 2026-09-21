import ArgumentParser
import Foundation
import FreeAgentAPI

struct BankTransactionListCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List bank transactions"
    )

    @Option(name: .long, help: "Bank account URL (e.g. https://api.freeagent.com/v2/bank_accounts/123)")
    var bankAccount: String

    @Option(name: .long, help: "Start date (YYYY-MM-DD)")
    var fromDate: String?

    @Option(name: .long, help: "End date (YYYY-MM-DD)")
    var toDate: String?

    @Option(name: .long, help: "Filter by view (e.g. unexplained)")
    var view: String?

    @Option(name: .long, help: "Show transactions updated after this date")
    var updatedSince: String?

    @Option(name: .long, help: "Show only last uploaded transactions (true/false)")
    var lastUploaded: String?

    @Option(name: .long, help: "Maximum number of bank transactions to fetch")
    var limit = ListLimit.default

    func run(client: Client) async throws -> Components.Schemas.BankTransactionListResponse? {
        let transactions = try await Paginator.collect(limit: limit.value) { page, perPage in
            let ok = try await client.listAllBankTransactionsUnderACertainBankAccount(
                .init(query: .init(
                    bankAccount: bankAccount,
                    fromDate: fromDate,
                    toDate: toDate,
                    updatedSince: updatedSince,
                    view: view,
                    lastUploaded: lastUploaded,
                    page: page,
                    perPage: perPage
                ))
            ).ok

            return (try ok.body.json.bankTransactions, ok.headers.xTotalCount)
        }

        return .init(bankTransactions: transactions)
    }
}
