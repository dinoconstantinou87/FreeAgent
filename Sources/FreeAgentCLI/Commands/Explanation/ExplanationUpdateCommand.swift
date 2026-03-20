import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct ExplanationUpdateCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update a bank transaction explanation"
    )

    @Argument(help: "Explanation ID")
    var id: String

    @Option(name: .long, help: "Category URL")
    var category: String?

    @Option(name: .long, help: "Description")
    var description: String?

    @Option(name: .long, help: "Gross value")
    var grossValue: String?

    @Option(name: .long, help: "User URL for DLA/salary payment")
    var paidUser: String?

    @Option(name: .long, help: "Path to file to attach (PDF or image)")
    var attachment: String?

    func run(client: Client) async throws -> OpenAPIObjectContainer? {
        var attachmentPayload: Components.Schemas.AttachmentPayload?

        if let attachmentPath = attachment {
            let url = URL(fileURLWithPath: attachmentPath)
            let data = try Data(contentsOf: url)
            let base64 = data.base64EncodedString()
            let fileName = url.lastPathComponent
            let ext = url.pathExtension.lowercased()
            let contentType: Components.Schemas.AttachmentPayload.ContentTypePayload = switch ext {
            case "pdf": .applicationXPdf
            case "png": .imagePng
            case "jpg", "jpeg": .imageJpeg
            case "gif": .imageGif
            default: .applicationXPdf
            }

            attachmentPayload = .init(
                data: base64,
                fileName: fileName,
                contentType: contentType
            )
        }

        let payload = Operations.UpdateABankTransactionExplanation.Input.Body.JsonPayload.BankTransactionExplanationPayload(
            attachment: attachmentPayload,
            category: category,
            description: description,
            grossValue: grossValue,
            paidUser: paidUser
        )

        let input = Operations.UpdateABankTransactionExplanation.Input(
            path: .init(id: id),
            body: .json(.init(bankTransactionExplanation: payload))
        )

        return try await client.updateABankTransactionExplanation(input)
            .ok.body.json.additionalProperties
    }
}
