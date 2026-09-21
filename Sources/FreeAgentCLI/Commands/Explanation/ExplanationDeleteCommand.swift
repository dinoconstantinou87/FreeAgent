import ArgumentParser
import Foundation
import FreeAgentAPI
import OpenAPIRuntime

struct ExplanationDeleteCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a bank transaction explanation"
    )

    @Argument(help: "Explanation ID")
    var id: String

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    var confirmation: String {
        "Delete explanation \(id)?"
    }

    func run(client: Client) async throws -> OpenAPIValueContainer? {
        let input = Operations.DeleteABankTransactionExplanation.Input(
            path: .init(id: id)
        )

        _ = try await client.deleteABankTransactionExplanation(input).ok
        return nil
    }
}
