import ArgumentParser
import Foundation
import FreeAgentAPI

struct ContactListCommand: ListCommand {
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
        Field("Status") { .status($0.status.rawValue) }
    }

    @OptionGroup var pagination: PaginationOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client, page: Int) async throws -> (response: Components.Schemas.ContactListResponse, totalCount: Int?) {
        let ok = try await client.listContacts(.init(query: .init(page: page, perPage: pagination.size))).ok

        return (try ok.body.json, ok.headers.xTotalCount)
    }

    func items(in response: Components.Schemas.ContactListResponse) -> [Components.Schemas.Contact] {
        response.contacts
    }
}
