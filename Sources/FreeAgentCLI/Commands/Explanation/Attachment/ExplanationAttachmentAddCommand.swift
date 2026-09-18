import ArgumentParser
import Foundation
import FreeAgentAPI

// MARK: - ExplanationAttachmentAddCommand

struct ExplanationAttachmentAddCommand: ClientCommand {

    // MARK: Internal

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
            let url = URL(fileURLWithPath: path)
            let ext = url.pathExtension.lowercased()

            guard let contentType = Self.contentTypes[ext] else {
                throw ExplanationAttachmentAddError.unsupportedFileType(ext)
            }

            return try Components.Schemas.AttachmentCreatePayload(
                data: Data(contentsOf: url).base64EncodedString(),
                fileName: url.lastPathComponent,
                contentType: contentType,
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

    // MARK: Private

    private static let contentTypes = [
        "pdf": "application/pdf",
        "png": "image/png",
        "jpg": "image/jpeg",
        "jpeg": "image/jpeg",
        "gif": "image/gif",
    ]

}

// MARK: - ExplanationAttachmentAddError

enum ExplanationAttachmentAddError: Error, CustomStringConvertible {
    case unsupportedFileType(String)

    var description: String {
        switch self {
        case .unsupportedFileType(let ext):
            "Unsupported attachment type '\(ext)'. Supported types: pdf, png, jpg, jpeg, gif"
        }
    }
}
