import ArgumentParser
import Foundation
import FreeAgentAPI

struct ContactListCommand: ListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List contacts"
    )

    static let noun = "contacts"

    static let columns: [ListColumn<Components.Schemas.Contact>] = [
        ListColumn("ID") { .id(url: $0.url) },
        ListColumn("Organisation") { .text($0.organisationName) },
        ListColumn("Name") { contact in
            let name = [contact.firstName, contact.lastName].compactMap(\.self).joined(separator: " ")

            return .text(name.isEmpty ? nil : name)
        },
        ListColumn("Email") { .text($0.email) },
        ListColumn("Status") { .status($0.status.rawValue) },
    ]

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
