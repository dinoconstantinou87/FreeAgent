import ArgumentParser
import Foundation
import FreeAgentAPI
import OpenAPIRuntime

struct BankTransactionListCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List bank transactions"
    )

    @Option(name: .long, help: "Bank account URL (e.g. https://api.freeagent.com/v2/bank_accounts/123)")
    var bankAccount: String?

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

    @Option(name: .long, help: "Page number")
    var page: Int?

    @Option(name: .long, help: "Results per page (max 100)")
    var perPage: Int?

    func run(client: Client) async throws -> OpenAPIObjectContainer? {
        let input = Operations.ListAllBankTransactionsUnderACertainBankAccount.Input(
            query: .init(
                bankAccount: bankAccount,
                fromDate: fromDate,
                toDate: toDate,
                updatedSince: updatedSince,
                view: view,
                lastUploaded: lastUploaded,
                page: page,
                perPage: perPage
            )
        )

        return try await client.listAllBankTransactionsUnderACertainBankAccount(input)
            .ok.body.json.additionalProperties
    }
}
