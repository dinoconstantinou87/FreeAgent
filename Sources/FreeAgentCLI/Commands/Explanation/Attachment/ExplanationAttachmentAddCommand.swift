import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora

// MARK: - ExplanationAttachmentAddCommand

struct ExplanationAttachmentAddCommand: MutatingCommand {

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

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.AttachmentListResponse {
        let attachments = try file.map { path in
            let url = URL(fileURLWithPath: path)
            let ext = url.pathExtension.lowercased()

            guard let contentType = Self.contentTypes[ext] else {
                throw ExplanationAttachmentAddCommandError.unsupportedFileType(ext)
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

    func success(for _: Components.Schemas.AttachmentListResponse) -> String {
        file.count == 1
            ? "Added the attachment to explanation \(id)"
            : "Added \(file.count) attachments to explanation \(id)"
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

// MARK: - ExplanationAttachmentAddCommandError

enum ExplanationAttachmentAddCommandError: CommandError {
    case unsupportedFileType(String)

    var errorDescription: String? {
        switch self {
        case .unsupportedFileType(let ext):
            "Unsupported attachment type '\(ext)'"
        }
    }

    var exitCode: ExitCode {
        .validationFailure
    }

    var takeaways: [TerminalText] {
        switch self {
        case .unsupportedFileType:
            ["Attach a pdf, png, jpg, jpeg or gif file"]
        }
    }
}
