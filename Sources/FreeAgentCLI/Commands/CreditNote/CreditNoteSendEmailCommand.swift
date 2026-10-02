import ArgumentParser
import Foundation
import FreeAgentAPI

struct CreditNoteSendEmailCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "send-email",
        abstract: "Send credit note via email"
    )

    @Argument(help: "Credit note ID or URL")
    var id: ResourceID

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

    func perform(client: Client) async throws -> EmptyResponse {
        let emailPayload = Components.Schemas.EmailPayload(
            body: body,
            from: from,
            subject: subject,
            to: to
        )

        let creditNotePayload = Operations.SendCreditNoteEmail.Input.Body.JsonPayload.CreditNotePayload(
            email: emailPayload
        )

        let input = Operations.SendCreditNoteEmail.Input(
            path: .init(id: id.value),
            body: .json(.init(creditNote: creditNotePayload))
        )

        _ = try await client.sendCreditNoteEmail(input).ok
        return EmptyResponse()
    }

    func success(for _: EmptyResponse) -> String {
        "Sent credit note \(id) to \(to)"
    }
}
