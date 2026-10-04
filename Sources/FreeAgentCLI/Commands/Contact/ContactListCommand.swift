import ArgumentParser
import Foundation
import FreeAgentAPI

struct ContactListCommand: AsyncPaginatedListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List contacts"
    )

    static let noun = "contacts"

    static var columns: [Field<Components.Schemas.Contact>] {
        Field("ID") { .id(url: $0.url) }
        Field("Organisation") { .text($0.organisationName) }
        Field("Name") { .text([$0.firstName, $0.lastName].compactMap(\.self).joined(separator: " ")) }
        Field("Email") { .text($0.email) }
        Field("Status") { .status($0.status) }
    }

    @Option(name: .long, help: "Filter by view - active by default, which leaves out hidden contacts")
    var view: Operations.ListContacts.Input.Query.ViewPayload?

    @Option(name: .long, parsing: .unconditional, help: "Sort order")
    var sort: Operations.ListContacts.Input.Query.SortPayload?

    @Option(name: .long, help: "Show contacts updated after this timestamp")
    var updatedSince: String?

    @OptionGroup var pagination: PaginationOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(
        client: Client,
        page: Int
    ) async throws -> (response: Components.Schemas.ContactListResponse, totalCount: Int?) {
        let ok = try await client.listContacts(
            .init(query: .init(
                view: view,
                sort: sort,
                updatedSince: updatedSince,
                page: page,
                perPage: pagination.size
            ))
        ).ok

        return (try ok.body.json, ok.headers.xTotalCount)
    }

    func items(in response: Components.Schemas.ContactListResponse) -> [Components.Schemas.Contact] {
        response.contacts
    }
}
