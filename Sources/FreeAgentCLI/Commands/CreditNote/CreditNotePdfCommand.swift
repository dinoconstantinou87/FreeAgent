import ArgumentParser
import Foundation
import FreeAgentAPI

struct CreditNotePdfCommand: PdfCommand {
    static let configuration = CommandConfiguration(
        commandName: "pdf",
        abstract: "Save a credit note as a PDF"
    )

    static let noun = "credit note"

    @Argument(help: "Credit note ID or URL")
    var id: ResourceID

    @Option(name: .long, help: "File to save the PDF to (default: credit-note-<id>.pdf)")
    var output: String?

    @Flag(name: .long, help: "Overwrite the file if it already exists")
    var clobber = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.PdfResponse {
        try await client.showCreditNoteAsPdf(.init(path: .init(id: id.value))).ok.body.json
    }
}
