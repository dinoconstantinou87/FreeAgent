import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExplanationListCommand: ListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List bank transaction explanations"
    )

    static let noun = "explanations"

    static var columns: [Field<Components.Schemas.BankTransactionExplanation>] {
        Field("ID") { .id(url: $0.url) }
        Field("Dated On") { .date($0.datedOn) }
        Field("Description") { .text($0.description) }
        Field("Gross Value") { .currency($0.grossValue, code: nil) }
    }

    @Option(name: .long, help: "Bank account URL (e.g. https://api.freeagent.com/v2/bank_accounts/123)")
    var bankAccount: String

    @Option(name: .long, help: "Start date (YYYY-MM-DD)")
    var fromDate: String?

    @Option(name: .long, help: "End date (YYYY-MM-DD)")
    var toDate: String?

    @Option(name: .long, help: "Show explanations updated after this date")
    var updatedSince: String?

    @OptionGroup var pagination: PaginationOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(
        client: Client,
        page: Int
    ) async throws -> (response: Components.Schemas.BankTransactionExplanationListResponse, totalCount: Int?) {
        let ok = try await client.listAllBankTransactionExplanations(
            .init(query: .init(
                fromDate: fromDate,
                toDate: toDate,
                updatedSince: updatedSince,
                bankAccount: bankAccount,
                page: page,
                perPage: pagination.size
            ))
        ).ok

        return (try ok.body.json, ok.headers.xTotalCount)
    }

    func items(
        in response: Components.Schemas.BankTransactionExplanationListResponse
    ) -> [Components.Schemas.BankTransactionExplanation] {
        response.bankTransactionExplanations
    }
}
