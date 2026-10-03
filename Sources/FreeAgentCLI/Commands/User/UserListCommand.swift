import ArgumentParser
import Foundation
import FreeAgentAPI

struct UserListCommand: AsyncPaginatedListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List users"
    )

    static let noun = "users"

    static var columns: [Field<Components.Schemas.User>] {
        Field("ID") { .id(url: $0.url) }
        Field("First Name") { .text($0.firstName) }
        Field("Last Name") { .text($0.lastName) }
        Field("Email") { .text($0.email) }
        Field("Role") { .text($0.role) }
        Field("Permission") { .text($0.permissionLevel.map(PermissionLevel.name(for:))) }
        Field("Hidden") { .flag($0.hidden) }
    }

    @Option(name: .long, help: "Filter by role and visibility - every user is listed by default")
    var view: Operations.ListUsers.Input.Query.ViewPayload?

    @OptionGroup var pagination: PaginationOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(
        client: Client,
        page: Int
    ) async throws -> (response: Components.Schemas.UserListResponse, totalCount: Int?) {
        let ok = try await client.listUsers(
            .init(query: .init(
                view: view,
                page: page,
                perPage: pagination.size
            ))
        ).ok

        return (try ok.body.json, ok.headers.xTotalCount)
    }

    func items(in response: Components.Schemas.UserListResponse) -> [Components.Schemas.User] {
        response.users
    }
}
