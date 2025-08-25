import ArgumentParser
import FreeAgentAPI
import Foundation
import OpenAPIRuntime

struct InvoiceTimelineCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "timeline",
        abstract: "Get invoice timeline"
    )
    
    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIObjectContainer? {
        let input = Operations.GetInvoiceTimeline.Input()
        
        let response = try await client.getInvoiceTimeline(input)
        
        switch response {
        case .ok(let okResponse):
            return try okResponse.body.json.additionalProperties
        default:
            return nil
        }
    }
}