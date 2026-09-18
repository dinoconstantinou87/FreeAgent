import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExplanationAttachmentListCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List attachments on a bank transaction explanation"
    )

    @Argument(help: "Explanation ID")
    var id: String

    func run(client: Client) async throws -> Components.Schemas.AttachmentListResponse? {
        let input = Operations.ListBankTransactionExplanationAttachments.Input(
            path: .init(id: id)
        )

        return try await client.listBankTransactionExplanationAttachments(input)
            .ok.body.json
    }
}
