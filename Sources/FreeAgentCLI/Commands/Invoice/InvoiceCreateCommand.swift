import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct InvoiceCreateCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new invoice"
    )
    
    @Argument(help: "Contact ID for the invoice")
    var contact: String
    
    @Option(name: .long, help: "Invoice dated on (YYYY-MM-DD)")
    var datedOn: String?
    
    @Option(name: .long, help: "Due date (YYYY-MM-DD)")
    var dueOn: String?
    
    @Option(name: .long, help: "Currency (e.g., GBP, USD)")
    var currency: String?
    
    @Option(name: .long, help: "Payment terms in days")
    var paymentTermsInDays: Double?
    
    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIObjectContainer? {
        let invoicePayload = Operations.CreateInvoice.Input.Body.JsonPayload.InvoicePayload(
            contact: contact,
            currency: currency,
            datedOn: datedOn,
            dueOn: dueOn,
            paymentTermsInDays: paymentTermsInDays
        )
        
        let input = Operations.CreateInvoice.Input(
            body: .json(.init(invoice: invoicePayload))
        )
        
        let response = try await client.createInvoice(input)
        
        switch response {
        case .ok(let okResponse):
            return try okResponse.body.json.additionalProperties
        default:
            return nil
        }
    }
}