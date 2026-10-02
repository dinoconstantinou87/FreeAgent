import ArgumentParser
import Foundation
import FreeAgentAPI

struct CreditNoteUpdateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update a draft credit note"
    )

    @Argument(help: "Credit note ID or URL")
    var id: ResourceID

    @Option(name: .long, help: "Credit note dated on (YYYY-MM-DD)")
    var datedOn: String?

    @Option(name: .long, help: "Payment terms in days, which set the due date")
    var paymentTermsInDays: Int?

    @Option(name: .long, help: "Reference")
    var reference: String?

    @Option(name: .long, help: "Comments for the credit note")
    var comments: String?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.CreditNoteResponse {
        let creditNotePayload = Components.Schemas.CreditNoteUpdatePayload(
            datedOn: datedOn,
            paymentTermsInDays: paymentTermsInDays,
            reference: reference,
            comments: comments
        )

        let input = Operations.UpdateCreditNote.Input(
            path: .init(id: id.value),
            body: .json(.init(creditNote: creditNotePayload))
        )

        return try await client.updateCreditNote(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.CreditNoteResponse) -> String {
        "Updated credit note \(id)"
    }
}
