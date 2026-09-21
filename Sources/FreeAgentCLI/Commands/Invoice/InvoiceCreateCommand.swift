import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceCreateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new invoice"
    )

    @Option(name: .long, help: "Contact ID for the invoice")
    var contact: String

    @Option(name: .long, help: "Invoice dated on (YYYY-MM-DD)")
    var datedOn: String

    @Option(name: .long, help: "Due date (YYYY-MM-DD)")
    var dueOn: String?

    @Option(name: .long, help: "Currency (e.g., GBP, USD)")
    var currency: String?

    @Option(name: .long, help: "Payment terms in days")
    var paymentTermsInDays: Double

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    func run(client: Client) async throws -> Components.Schemas.InvoiceResponse? {
        let invoicePayload = Components.Schemas.InvoiceCreatePayload(
            contact: contact,
            currency: currency,
            datedOn: datedOn,
            dueOn: dueOn,
            paymentTermsInDays: paymentTermsInDays
        )

        let input = Operations.CreateInvoice.Input(
            body: .json(.init(invoice: invoicePayload))
        )

        return try await client.createInvoice(input)
            .created.body.json
    }
}
