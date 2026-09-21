import ArgumentParser
import Foundation
import FreeAgentAPI
import OpenAPIRuntime

struct InvoiceSendEmailCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "send-email",
        abstract: "Send invoice via email"
    )

    @Argument(help: "Invoice ID")
    var id: String

    @Option(name: .long, help: "Recipient email address")
    var to: String

    @Option(name: .long, help: "Sender email address, must be verified on the FreeAgent account")
    var from: String?

    @Option(name: .long, help: "Email body")
    var body: String?

    @Option(name: .long, help: "Email subject")
    var subject: String?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIValueContainer? {
        let emailPayload = Components.Schemas.EmailPayload(
            body: body,
            from: from,
            subject: subject,
            to: to
        )

        let invoicePayload = Operations.SendInvoiceEmail.Input.Body.JsonPayload.InvoicePayload(
            email: emailPayload
        )

        let input = Operations.SendInvoiceEmail.Input(
            path: .init(id: id),
            body: .json(.init(invoice: invoicePayload))
        )

        _ = try await client.sendInvoiceEmail(input).ok
        return nil
    }
}
