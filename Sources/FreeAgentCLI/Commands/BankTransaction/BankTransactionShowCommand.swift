import ArgumentParser
import Foundation
import FreeAgentAPI

struct BankTransactionShowCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show bank transaction details"
    )

    @Argument(help: "Bank transaction ID")
    var id: String

    func run(client: Client) async throws -> Components.Schemas.BankTransactionResponse? {
        let input = Operations.GetASingleBankTransaction.Input(
            path: .init(id: id)
        )

        return try await client.getASingleBankTransaction(input)
            .ok.body.json
    }
}
