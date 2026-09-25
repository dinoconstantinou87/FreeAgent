import ArgumentParser
import Foundation
import FreeAgentAPI

struct InvoiceTimelineCommand: PaginatedListCommand {
    static let configuration = CommandConfiguration(
        commandName: "timeline",
        abstract: "Get invoice timeline"
    )

    static let noun = "timeline items"

    static var columns: [Field<Components.Schemas.InvoiceTimelineItem>] {
        Field("Dated On") { .date($0.datedOn) }
        Field("Reference") { .text($0.reference) }
        Field("Description") { .text($0.description) }
        Field("Summary") { .text($0.summary) }
        Field("Amount") { .currency($0.amount, code: nil) }
    }

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.InvoiceTimelineResponse {
        try await client.getInvoiceTimeline(.init()).ok.body.json
    }

    func items(
        in response: Components.Schemas.InvoiceTimelineResponse
    ) -> [Components.Schemas.InvoiceTimelineItem] {
        response.invoiceTimelineItems
    }
}
