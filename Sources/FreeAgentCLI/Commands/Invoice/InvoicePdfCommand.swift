import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora

struct InvoicePdfCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "pdf",
        abstract: "Save an invoice as a PDF"
    )

    @Argument(help: "Invoice ID")
    var id: String

    @Option(name: .long, help: "File to save the PDF to (default: invoice-<id>.pdf)")
    var output: String?

    @Flag(name: .long, help: "Overwrite the file if it already exists")
    var clobber = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    var path: String {
        output ?? "invoice-\(id).pdf"
    }

    func canRun() throws -> Bool {
        guard !json, FileManager.default.fileExists(atPath: path) else {
            return true
        }

        return switch ConfirmationDecision(yes: clobber, dryRun: false, isInteractive: Terminal.canPrompt()) {
        case .proceed:
            true
        case .refuse:
            throw CommandRefusal.fileExists(path: path)
        case .prompt:
            Noora().yesOrNoChoicePrompt(question: "Overwrite \(path)?", defaultAnswer: false)
        }
    }

    func run(client: Client) async throws -> Components.Schemas.InvoicePdfResponse? {
        let response = try await client.showInvoiceAsPdf(.init(path: .init(id: id))).ok.body.json

        if json {
            return response
        }

        guard
            let content = response.pdf.content,
            let data = Data(base64Encoded: content, options: .ignoreUnknownCharacters)
        else {
            throw APIError(kind: .unexpected)
        }

        try data.write(to: URL(fileURLWithPath: path), options: .atomic)
        Noora().success(.alert("Saved invoice \(id) to \(path)"))

        return nil
    }
}
