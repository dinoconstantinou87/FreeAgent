import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExplanationAttachmentAddCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add attachments to a bank transaction explanation",
        discussion: "Adds up to 10 files per call, to a maximum of 50 attachments per explanation."
    )

    @Argument(help: "Explanation ID or URL")
    var id: ResourceID

    @Option(name: .long, help: "Path to a file to attach (pdf, png, jpg, jpeg or gif). Repeat for multiple files.")
    var file: [String]

    @Option(name: .long, help: "Description applied to each attached file")
    var description: String?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.AttachmentListResponse {
        let attachments = try file.map { path in
            let attachment = try AttachmentFile(path: path)

            return Components.Schemas.AttachmentCreatePayload(
                data: attachment.data,
                fileName: attachment.fileName,
                contentType: attachment.contentType,
                description: description
            )
        }

        let input = Operations.CreateBankTransactionExplanationAttachments.Input(
            path: .init(id: id.value),
            body: .json(.init(attachments: attachments))
        )

        return try await client.createBankTransactionExplanationAttachments(input)
            .created.body.json
    }

    func success(for _: Components.Schemas.AttachmentListResponse) -> String {
        file.count == 1
            ? "Added the attachment to explanation \(id)"
            : "Added \(file.count) attachments to explanation \(id)"
    }
}
