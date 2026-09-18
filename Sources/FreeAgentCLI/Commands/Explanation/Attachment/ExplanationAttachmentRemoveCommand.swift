import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExplanationAttachmentRemoveCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "remove",
        abstract: "Remove attachments from a bank transaction explanation"
    )

    @Argument(help: "Explanation ID")
    var id: String

    @Option(name: .long, help: "URL of an attachment to remove. Repeat for multiple attachments.")
    var attachment: [String]

    func run(client: Client) async throws -> Components.Schemas.AttachmentListResponse? {
        let attachments = attachment.map {
            Components.Schemas.AttachmentUpdatePayload(url: $0, _destroy: "true")
        }

        let input = Operations.UpdateBankTransactionExplanationAttachments.Input(
            path: .init(id: id),
            body: .json(.init(attachments: attachments))
        )

        return try await client.updateBankTransactionExplanationAttachments(input)
            .ok.body.json
    }
}
