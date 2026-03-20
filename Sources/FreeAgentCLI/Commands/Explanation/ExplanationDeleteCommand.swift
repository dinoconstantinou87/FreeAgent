import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct ExplanationDeleteCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a bank transaction explanation"
    )

    @Argument(help: "Explanation ID")
    var id: String

    func run(client: Client) async throws -> OpenAPIValueContainer? {
        let input = Operations.DeleteABankTransactionExplanation.Input(
            path: .init(id: id)
        )

        _ = try await client.deleteABankTransactionExplanation(input).ok
        return nil
    }
}
