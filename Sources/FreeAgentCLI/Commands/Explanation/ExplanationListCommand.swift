import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExplanationListCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List bank transaction explanations"
    )

    @Option(name: .long, help: "Bank account URL (e.g. https://api.freeagent.com/v2/bank_accounts/123)")
    var bankAccount: String

    @Option(name: .long, help: "Start date (YYYY-MM-DD)")
    var fromDate: String?

    @Option(name: .long, help: "End date (YYYY-MM-DD)")
    var toDate: String?

    @Option(name: .long, help: "Show explanations updated after this date")
    var updatedSince: String?

    @Option(name: .long, help: "Maximum number of explanations to fetch")
    var limit = ListLimit.default

    func run(client: Client) async throws -> Components.Schemas.BankTransactionExplanationListResponse? {
        let explanations = try await Paginator.collect(limit: limit.value) { page, perPage in
            let ok = try await client.listAllBankTransactionExplanations(
                .init(query: .init(
                    fromDate: fromDate,
                    toDate: toDate,
                    updatedSince: updatedSince,
                    bankAccount: bankAccount,
                    page: page,
                    perPage: perPage
                ))
            ).ok

            return (try ok.body.json.bankTransactionExplanations, ok.headers.xTotalCount)
        }

        return .init(bankTransactionExplanations: explanations)
    }
}
