import ArgumentParser
import Foundation
import FreeAgentAPI

struct TaskListCommand: AsyncPaginatedListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List tasks"
    )

    static let noun = "tasks"

    static var columns: [Field<Components.Schemas.Task>] {
        Field("ID") { .id(url: $0.url) }
        Field("Name") { .text($0.name) }
        Field("Project") { .id(url: $0.project) }
        Field("Status") { .status($0.status) }
        Field("Billable") { .flag($0.isBillable) }
        Field("Billing Rate") { .currency($0.billingRate, code: $0.currency) }
        Field("Billing Period") { .text($0.billingPeriod) }
    }

    @Option(name: .long, help: "Filter by status - every status is listed by default")
    var view: Operations.ListTasks.Input.Query.ViewPayload?

    @Option(name: .long, parsing: .unconditional, help: "Sort order")
    var sort: Operations.ListTasks.Input.Query.SortPayload?

    @Option(name: .long, help: "Filter by project ID or URL")
    var project: ResourceID?

    @Option(name: .long, help: "Show tasks updated since this date or timestamp")
    var updatedSince: String?

    @OptionGroup var pagination: PaginationOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(
        client: Client,
        page: Int
    ) async throws -> (response: Components.Schemas.TaskListResponse, totalCount: Int?) {
        let ok = try await client.listTasks(
            .init(query: .init(
                view: view,
                sort: sort,
                project: project?.value,
                updatedSince: updatedSince,
                page: page,
                perPage: pagination.size
            ))
        ).ok

        return (try ok.body.json, ok.headers.xTotalCount)
    }

    func items(in response: Components.Schemas.TaskListResponse) -> [Components.Schemas.Task] {
        response.tasks
    }
}
