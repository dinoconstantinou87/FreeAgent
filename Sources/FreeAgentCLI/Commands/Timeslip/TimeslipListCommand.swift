import ArgumentParser
import Foundation
import FreeAgentAPI

struct TimeslipListCommand: AsyncPaginatedListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List timeslips"
    )

    static let noun = "timeslips"

    static var columns: [Field<Components.Schemas.Timeslip>] {
        Field("ID") { .id(url: $0.url) }
        Field("Dated On") { .date($0.datedOn) }
        Field("Hours") { .hours($0.hours) }
        Field("Running") { .flag($0.timer?.running) }
        Field("Project") { .id(url: $0.project) }
        Field("Task") { .id(url: $0.task) }
        Field("User") { .id(url: $0.user) }
        Field("Comment") { .text($0.comment) }
    }

    @Option(name: .long, help: "Filter by view")
    var view: Operations.ListTimeslips.Input.Query.ViewPayload?

    @Option(name: .long, help: "Filter by user ID or URL")
    var user: ResourceID?

    @Option(name: .long, help: "Filter by project ID or URL")
    var project: ResourceID?

    @Option(name: .long, help: "Filter by task ID or URL")
    var task: ResourceID?

    @Option(name: .long, help: "Show timeslips dated on or after this date (YYYY-MM-DD)")
    var fromDate: String?

    @Option(name: .long, help: "Show timeslips dated on or before this date (YYYY-MM-DD)")
    var toDate: String?

    @Option(name: .long, help: "Show timeslips updated after this timestamp")
    var updatedSince: String?

    @Option(name: .long, parsing: .unconditional, help: "Sort order")
    var sort: Operations.ListTimeslips.Input.Query.SortPayload?

    @OptionGroup var pagination: PaginationOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(
        client: Client,
        page: Int
    ) async throws -> (response: Components.Schemas.TimeslipListResponse, totalCount: Int?) {
        let ok = try await client.listTimeslips(
            .init(query: .init(
                user: user?.value,
                project: project?.value,
                task: task?.value,
                view: view,
                fromDate: fromDate,
                toDate: toDate,
                updatedSince: updatedSince,
                sort: sort,
                page: page,
                perPage: pagination.size
            ))
        ).ok

        return (try ok.body.json, ok.headers.xTotalCount)
    }

    func items(in response: Components.Schemas.TimeslipListResponse) -> [Components.Schemas.Timeslip] {
        response.timeslips
    }
}
