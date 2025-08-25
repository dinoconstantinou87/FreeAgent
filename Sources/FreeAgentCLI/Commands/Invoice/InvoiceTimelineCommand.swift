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
        let okResponse = try response.ok
        return try okResponse.body.json.additionalProperties
    }
}