import ArgumentParser
import Foundation
import FreeAgentAPI

struct JournalSetUpdateCommand: MutatingCommand {

    // MARK: Internal

    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update a journal set",
        discussion: """
            Fields left out are kept. Passing --entry replaces every entry with the ones given, in one request, \
            so they must balance on their own.
            """
    )

    @Argument(help: "Journal set ID or URL")
    var id: ResourceID

    @Option(name: .long, help: "Date of the entries (YYYY-MM-DD)")
    var datedOn: String?

    @Option(name: .long, help: "Description")
    var description: String?

    @Option(name: .long, help: "Tag identifying sets your tool creates - an empty string removes it")
    var tag: String?

    @Option(name: .long, help: ArgumentHelp(JournalEntryArgument.help), transform: JournalEntryArgument.init)
    var entry = [JournalEntryArgument]()

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.JournalSetResponse {
        let journalSetPayload = try await Components.Schemas.JournalSetUpdatePayload(
            datedOn: datedOn,
            description: description,
            tag: tag,
            journalEntries: journalEntries(client: client)
        )

        let input = Operations.UpdateJournalSet.Input(
            path: .init(id: id.value),
            body: .json(.init(journalSet: journalSetPayload))
        )

        return try await client.updateJournalSet(input)
            .ok.body.json
    }

    func success(for _: Components.Schemas.JournalSetResponse) -> String {
        "Updated journal set \(id)"
    }

    // MARK: Private

    private func journalEntries(client: Client) async throws -> [Components.Schemas.JournalEntryPayload]? {
        guard !entry.isEmpty else {
            return nil
        }

        let current = try await client.showJournalSet(.init(path: .init(id: id.value)))
            .ok.body.json.journalSet.journalEntries ?? []

        return current.map { .init(url: $0.url, _destroy: true) } + entry.map(\.payload)
    }
}
