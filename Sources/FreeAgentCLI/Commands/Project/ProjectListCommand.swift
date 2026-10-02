import ArgumentParser
import Foundation
import FreeAgentAPI

struct ProjectListCommand: AsyncPaginatedListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List projects"
    )

    static let noun = "projects"

    static var columns: [Field<Components.Schemas.Project>] {
        Field("ID") { .id(url: $0.url) }
        Field("Name") { .text($0.name) }
        Field("Contact") { .text($0.contactName) }
        Field("Status") { .status($0.status?.rawValue) }
        Field("Starts On") { .date($0.startsOn) }
        Field("Ends On") { .date($0.endsOn) }
    }

    @Option(name: .long, help: "Filter by status - every status is listed by default")
    var view: Operations.ListProjects.Input.Query.ViewPayload?

    @Option(name: .long, parsing: .unconditional, help: "Sort order")
    var sort: Operations.ListProjects.Input.Query.SortPayload?

    @Option(name: .long, help: "Filter by contact ID or URL")
    var contact: ResourceID?

    @OptionGroup var pagination: PaginationOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(
        client: Client,
        page: Int
    ) async throws -> (response: Components.Schemas.ProjectListResponse, totalCount: Int?) {
        let ok = try await client.listProjects(
            .init(query: .init(
                view: view,
                sort: sort,
                contact: contact?.value,
                page: page,
                perPage: pagination.size
            ))
        ).ok

        return (try ok.body.json, ok.headers.xTotalCount)
    }

    func items(in response: Components.Schemas.ProjectListResponse) -> [Components.Schemas.Project] {
        response.projects
    }
}
