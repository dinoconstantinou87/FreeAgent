import ArgumentParser
import Foundation
import FreeAgentAPI

struct BankTransactionListCommand: ListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List bank transactions"
    )

    static let noun = "bank transactions"

    static var columns: [Field<Components.Schemas.BankTransaction>] {
        Field("ID") { .id(url: $0.url) }
        Field("Dated On") { .date($0.datedOn) }
        Field("Description") { .text($0.description) }
        Field("Amount") { .currency($0.amount, code: nil) }
        Field("Unexplained") { .currency($0.unexplainedAmount, code: nil) }
    }

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

    @OptionGroup var pagination: PaginationOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(
        client: Client,
        page: Int
    ) async throws -> (response: Components.Schemas.BankTransactionListResponse, totalCount: Int?) {
        let ok = try await client.listAllBankTransactionsUnderACertainBankAccount(
            .init(query: .init(
                bankAccount: bankAccount,
                fromDate: fromDate,
                toDate: toDate,
                updatedSince: updatedSince,
                view: view,
                lastUploaded: lastUploaded,
                page: page,
                perPage: pagination.size
            ))
        ).ok

        return (try ok.body.json, ok.headers.xTotalCount)
    }

    func items(in response: Components.Schemas.BankTransactionListResponse) -> [Components.Schemas.BankTransaction] {
        response.bankTransactions
    }
}
