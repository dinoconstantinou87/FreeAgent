import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceTimelineCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "timeline",
        abstract: "Get invoice timeline"
    )

    func run(client: Client) async throws -> Components.Schemas.InvoiceTimelineResponse? {
        let input = Operations.GetInvoiceTimeline.Input()

        return try await client.getInvoiceTimeline(input)
            .ok.body.json
    }
}
