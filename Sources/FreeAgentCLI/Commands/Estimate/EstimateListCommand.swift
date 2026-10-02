import ArgumentParser
import Foundation
import FreeAgentAPI

struct EstimateListCommand: AsyncPaginatedListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List estimates"
    )

    static let noun = "estimates"

    static var columns: [Field<Components.Schemas.Estimate>] {
        Field("ID") { .id(url: $0.url) }
        Field("Reference") { .text($0.reference) }
        Field("Type") { .text($0.estimateType) }
        Field("Contact") { .text($0.contactName) }
        Field("Dated On") { .date($0.datedOn) }
        Field("Status") { .status($0.status) }
        Field("Total") { .currency($0.totalValue, code: $0.currency) }
    }

    @Option(name: .long, help: "Filter by view")
    var view: Operations.ListEstimates.Input.Query.ViewPayload?

    @Option(name: .long, help: "Filter by contact ID or URL")
    var contact: ResourceID?

    @Option(name: .long, help: "Filter by project ID or URL")
    var project: ResourceID?

    @Option(name: .long, help: "Filter by the ID or URL of the invoice an estimate was converted to")
    var invoice: ResourceID?

    @Option(name: .long, help: "Show estimates dated on or after this date (YYYY-MM-DD)")
    var fromDate: String?

    @Option(name: .long, help: "Show estimates dated on or before this date (YYYY-MM-DD)")
    var toDate: String?

    @Option(name: .long, help: "Show estimates updated after this timestamp")
    var updatedSince: String?

    @Option(name: .long, help: "Include estimate items nested within each estimate")
    var nestedEstimateItems: Bool?

    @OptionGroup var pagination: PaginationOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client, page: Int) async throws -> (response: Components.Schemas.EstimateListResponse, totalCount: Int?) {
        let ok = try await client.listEstimates(
            .init(query: .init(
                nestedEstimateItems: nestedEstimateItems,
                contact: contact?.value,
                project: project?.value,
                invoice: invoice?.value,
                view: view,
                fromDate: fromDate,
                toDate: toDate,
                updatedSince: updatedSince,
                page: page,
                perPage: pagination.size
            ))
        ).ok

        return (try ok.body.json, ok.headers.xTotalCount)
    }

    func items(in response: Components.Schemas.EstimateListResponse) -> [Components.Schemas.Estimate] {
        response.estimates
    }
}
