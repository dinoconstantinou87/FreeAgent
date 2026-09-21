import ArgumentParser
import Foundation
import FreeAgentAPI

struct ContactListCommand: ClientCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List contacts"
    )

    @Option(name: .long, help: "Maximum number of contacts to fetch")
    var limit = ListLimit.default

    func run(client: Client) async throws -> Components.Schemas.ContactListResponse? {
        let contacts = try await Paginator.collect(limit: limit.value) { page, perPage in
            let ok = try await client.listContacts(.init(query: .init(page: page, perPage: perPage))).ok

            return (try ok.body.json.contacts, ok.headers.xTotalCount)
        }

        return .init(contacts: contacts)
    }
}
