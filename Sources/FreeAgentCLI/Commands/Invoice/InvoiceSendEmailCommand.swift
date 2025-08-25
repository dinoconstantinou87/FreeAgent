import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct InvoiceSendEmailCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "send-email",
        abstract: "Send invoice via email"
    )
    
    @Argument(help: "Invoice ID")
    var id: String
    
    @Option(name: .long, help: "Email body")
    var body: String?
    
    @Option(name: .long, help: "Email subject")
    var subject: String?
    
    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIObjectContainer? {
        let emailPayload = Operations.SendInvoiceEmail.Input.Body.JsonPayload.InvoicePayload.EmailPayload(
            body: body,
            subject: subject
        )
        
        let invoicePayload = Operations.SendInvoiceEmail.Input.Body.JsonPayload.InvoicePayload(
            email: emailPayload
        )
        
        let input = Operations.SendInvoiceEmail.Input(
            path: .init(id: id),
            body: .json(.init(invoice: invoicePayload))
        )
        
        let response = try await client.sendInvoiceEmail(input)
        
        switch response {
        case .ok(let okResponse):
            return try okResponse.body.json.additionalProperties
        default:
            return nil
        }
    }
}