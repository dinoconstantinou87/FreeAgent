import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct BankAccountShowCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show bank account details"
    )

    @Argument(help: "Bank account ID")
    var id: String

    func run(client: Client) async throws -> OpenAPIObjectContainer? {
        let input = Operations.ShowBankAccount.Input(
            path: .init(id: id)
        )

        return try await client.showBankAccount(input)
            .ok.body.json.additionalProperties
    }
}
