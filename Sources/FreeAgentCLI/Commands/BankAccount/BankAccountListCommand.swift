import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct BankAccountListCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List bank accounts"
    )

    @Option(name: .long, help: "Filter by view (e.g. standard_bank_accounts)")
    var view: String?

    func run(client: Client) async throws -> OpenAPIObjectContainer? {
        let input = Operations.ListBankAccounts.Input(
            query: .init(view: view)
        )

        return try await client.listBankAccounts(input)
            .ok.body.json.additionalProperties
    }
}
