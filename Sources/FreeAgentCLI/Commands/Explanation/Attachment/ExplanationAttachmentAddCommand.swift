import ArgumentParser
import Foundation
import FreeAgentAPI

struct ExplanationAttachmentAddCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add attachments to a bank transaction explanation",
        discussion: "Adds up to 10 files per call, to a maximum of 50 attachments per explanation."
    )

    @Argument(help: "Explanation ID")
    var id: String

    @Option(name: .long, help: "Path to a file to attach (pdf, png, jpg, jpeg or gif). Repeat for multiple files.")
    var file: [String]

    @Option(name: .long, help: "Description applied to each attached file")
    var description: String?

    func run(client: Client) async throws -> Components.Schemas.AttachmentListResponse? {
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
            path: .init(id: id),
            body: .json(.init(attachments: attachments))
        )

        return try await client.createBankTransactionExplanationAttachments(input)
            .created.body.json
    }
}
