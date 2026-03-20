import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct ExplanationListCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List bank transaction explanations"
    )

    @Option(name: .long, help: "Bank account URL (e.g. https://api.freeagent.com/v2/bank_accounts/123)")
    var bankAccount: String?

    @Option(name: .long, help: "Start date (YYYY-MM-DD)")
    var fromDate: String?

    @Option(name: .long, help: "End date (YYYY-MM-DD)")
    var toDate: String?

    @Option(name: .long, help: "Show explanations updated after this date")
    var updatedSince: String?

    func run(client: Client) async throws -> OpenAPIObjectContainer? {
        let input = Operations.ListAllBankTransactionExplanations.Input(
            query: .init(
                fromDate: fromDate,
                toDate: toDate,
                updatedSince: updatedSince,
                bankAccount: bankAccount
            )
        )

        return try await client.listAllBankTransactionExplanations(input)
            .ok.body.json.additionalProperties
    }
}
