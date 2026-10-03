import ArgumentParser
import Foundation
import FreeAgentAPI

struct JournalSetShowCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Show journal set details"
    )

    static let title = "Journal Set"

    static let tables = [
        FieldTable<Components.Schemas.JournalSet>("Entries", items: \.journalEntries) {
            Field("ID") { .id(url: $0.url) }
            Field("Category") { .id(url: $0.category) }
            Field("Description") { .text($0.description) }
            Field("User") { .id(url: $0.user) }
            Field("Contact") { .id(url: $0.contact) }
            Field("Debit Value") { .currency($0.debitValue, code: nil) }
        },
        FieldTable<Components.Schemas.JournalSet>("Bank Accounts", items: \.bankAccounts) {
            openingBalanceColumns
        },
        FieldTable<Components.Schemas.JournalSet>("Stock Items", items: \.stockItems) {
            openingBalanceColumns
        },
    ]

    static var sections: [FieldSection<Components.Schemas.JournalSet>] {
        FieldSection("Details") {
            Field("Description") { .text($0.description) }
            Field("Tag") { .text($0.tag) }
        }
        FieldSection("Dates") {
            Field("Dated On") { .date($0.datedOn) }
            Field("Updated") { .timestamp($0.updatedAt) }
        }
        FieldSection("IDs") {
            Field("Journal Set") { .id(url: $0.url) }
        }
    }

    @FieldBuilder<Components.Schemas.OpeningBalance>
    static var openingBalanceColumns: [Field<Components.Schemas.OpeningBalance>] {
        Field("ID") { .id(url: $0.url) }
        Field("Description") { .text($0.description) }
        Field("Debit Value") { .currency($0.debitValue, code: nil) }
    }

    @Argument(help: "Journal set ID or URL")
    var id: ResourceID

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.JournalSetResponse {
        try await client.showJournalSet(.init(path: .init(id: id.value))).ok.body.json
    }

    func record(in response: Components.Schemas.JournalSetResponse) -> Components.Schemas.JournalSet {
        response.journalSet
    }
}
