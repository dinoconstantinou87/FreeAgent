import ArgumentParser
import Foundation
import FreeAgentAPI
import OpenAPIRuntime

struct ExplanationShowCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show bank transaction explanation details"
    )

    @Argument(help: "Explanation ID")
    var id: String

    func run(client: Client) async throws -> OpenAPIObjectContainer? {
        let input = Operations.GetASingleBankTransactionExplanation.Input(
            path: .init(id: id)
        )

        return try await client.getASingleBankTransactionExplanation(input)
            .ok.body.json.additionalProperties
    }
}
