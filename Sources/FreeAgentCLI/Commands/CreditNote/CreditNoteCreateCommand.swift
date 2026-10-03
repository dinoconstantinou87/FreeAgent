import ArgumentParser
import Foundation
import FreeAgentAPI

struct CreditNoteCreateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a draft credit note"
    )

    @Option(name: .long, help: "Contact ID or URL")
    var contact: ResourceID

    @Option(name: .long, help: "Credit note dated on (YYYY-MM-DD)")
    var datedOn: String

    @Option(name: .long, help: "Payment terms in days, which set the due date (default: 0)")
    var paymentTermsInDays: Int?

    @Option(name: .long, help: "Reference (default: the next invoice reference)")
    var reference: String?

    @Option(name: .long, help: "Project ID or URL")
    var project: ResourceID?

    @Option(name: .long, help: "Currency")
    var currency: Components.Schemas.Currency?

    @Option(name: .long, help: "Comments for the credit note")
    var comments: String?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.CreditNoteResponse {
        let creditNotePayload = Components.Schemas.CreditNoteCreatePayload(
            contact: contact.value,
            project: project?.value,
            datedOn: datedOn,
            paymentTermsInDays: paymentTermsInDays,
            reference: reference,
            currency: currency,
            comments: comments
        )

        let input = Operations.CreateCreditNote.Input(
            body: .json(.init(creditNote: creditNotePayload))
        )

        return try await client.createCreditNote(input)
            .created.body.json
    }

    func success(for response: Components.Schemas.CreditNoteResponse) -> String {
        "Created credit note \(response.creditNote.url)"
    }
}
