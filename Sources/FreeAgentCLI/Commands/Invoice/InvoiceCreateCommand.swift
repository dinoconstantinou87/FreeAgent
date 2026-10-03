import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceCreateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new invoice"
    )

    @Option(name: .long, help: "Contact ID or URL")
    var contact: ResourceID

    @Option(name: .long, help: "Invoice dated on (YYYY-MM-DD)")
    var datedOn: String

    @Option(name: .long, help: "Due date (YYYY-MM-DD)")
    var dueOn: String?

    @Option(name: .long, help: "Currency (e.g., GBP, USD)")
    var currency: Components.Schemas.Currency?

    @Option(name: .long, help: "Payment terms in days")
    var paymentTermsInDays: Double

    @Option(name: .long, help: "Project ID or URL, which must belong to the contact")
    var project: ResourceID?

    @Option(
        name: .long,
        help: "Bill the project's unbilled timeslips onto the invoice, on one line or grouped by timeslip, task or date"
    )
    var includeTimeslips: Components.Schemas.InvoiceCreatePayload.IncludeTimeslipsPayload?

    @Option(
        name: .long,
        help: "Bill the expenses, bills and bank entries rebilled to the project onto the invoice, on one line or one per expense"
    )
    var includeExpenses: Components.Schemas.InvoiceCreatePayload.IncludeExpensesPayload?

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func validate() throws {
        if includeTimeslips != nil, project == nil {
            throw ValidationError("--include-timeslips needs --project, or FreeAgent bills no timeslips")
        }

        if includeExpenses != nil, project == nil {
            throw ValidationError("--include-expenses needs --project, or FreeAgent bills no expenses")
        }
    }

    func perform(client: Client) async throws -> Components.Schemas.InvoiceResponse {
        let invoicePayload = Components.Schemas.InvoiceCreatePayload(
            contact: contact.value,
            project: project?.value,
            includeTimeslips: includeTimeslips,
            includeExpenses: includeExpenses,
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

    func success(for response: Components.Schemas.InvoiceResponse) -> String {
        "Created invoice \(response.invoice.url)"
    }
}
