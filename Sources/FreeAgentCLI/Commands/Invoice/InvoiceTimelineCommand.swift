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
        
        return try await client.getInvoiceTimeline(input)
            .ok.body.json.additionalProperties
    }
}