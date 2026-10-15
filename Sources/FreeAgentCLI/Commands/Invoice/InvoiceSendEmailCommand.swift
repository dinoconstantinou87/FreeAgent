import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceSendEmailCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "send-email",
        abstract: "Send invoice via email"
    )

    @Argument(help: "Invoice ID or URL")
    var id: ResourceID

    @Option(name: .long, help: "Recipient email address")
    var to: String

    @Option(name: .long, help: "Sender email address, must be verified on the FreeAgent account")
    var from: String?

    @Option(name: .long, help: "Email body")
    var body: String?

    @Option(name: .long, help: "Email subject")
    var subject: String?

    @Option(
        name: .customLong("attachment"),
        help: "Path to a file to attach (pdf, png, jpg, jpeg or gif), up to 5MB. Repeat for multiple files."
    )
    var attachments = [String]()

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    func perform(client: Client) async throws -> EmptyResponse {
        let attachmentPayloads = try attachments.map { path in
            let file = try AttachmentFile(path: path)
            return Components.Schemas.EmailAttachmentPayload(
                data: file.data,
                fileName: file.fileName,
                contentType: file.contentType
            )
        }

        let emailPayload = Components.Schemas.EmailPayload(
            body: body,
            from: from,
            subject: subject,
            to: to,
            attachments: attachmentPayloads.isEmpty ? nil : attachmentPayloads
        )

        let invoicePayload = Operations.SendInvoiceEmail.Input.Body.JsonPayload.InvoicePayload(
            email: emailPayload
        )

        let input = Operations.SendInvoiceEmail.Input(
            path: .init(id: id.value),
            body: .json(.init(invoice: invoicePayload))
        )

        _ = try await client.sendInvoiceEmail(input).ok
        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Sent invoice \(id) to \(to)"
    }
}
