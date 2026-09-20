import ArgumentParser
import Foundation
import FreeAgentAPI

struct BankAccountShowCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show bank account details"
    )

    @Argument(help: "Bank account ID")
    var id: String

    func run(client: Client) async throws -> Components.Schemas.BankAccountResponse? {
        let input = Operations.ShowBankAccount.Input(
            path: .init(id: id)
        )

        return try await client.showBankAccount(input)
            .ok.body.json
    }
}
