import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExplanationAttachmentRemoveCommand: DestructiveCommand {
    static let configuration = CommandConfiguration(
        commandName: "remove",
        abstract: "Remove attachments from a bank transaction explanation"
    )

    @Argument(help: "Explanation ID")
    var id: String

    @Option(name: .long, help: "URL of an attachment to remove. Repeat for multiple attachments.")
    var attachment: [String]

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(help: "Skip the confirmation prompt")
    var yes = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    var confirmation: String {
        attachment.count == 1
            ? "Remove the attachment from explanation \(id)?"
            : "Remove \(attachment.count) attachments from explanation \(id)?"
    }

    func perform(client: Client) async throws -> Components.Schemas.AttachmentListResponse {
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

    func success(for _: Components.Schemas.AttachmentListResponse) -> String {
        attachment.count == 1
            ? "Removed the attachment from explanation \(id)"
            : "Removed \(attachment.count) attachments from explanation \(id)"
    }
}
