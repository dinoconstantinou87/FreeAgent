import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExplanationShowCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show bank transaction explanation details"
    )

    @Argument(help: "Explanation ID")
    var id: String

    func run(client: Client) async throws -> Components.Schemas.BankTransactionExplanationResponse? {
        let input = Operations.GetASingleBankTransactionExplanation.Input(
            path: .init(id: id)
        )

        return try await client.getASingleBankTransactionExplanation(input)
            .ok.body.json
    }
}
