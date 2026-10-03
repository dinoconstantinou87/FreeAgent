import ArgumentParser
import Foundation
import FreeAgentAPI

struct JournalSetCreateCommand: MutatingCommand {
    static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a journal set",
        discussion: """
            The entries must balance: their debit values, negative for credits, add up to zero. User categories \
            such as 901 and 907 need a user, and capital asset categories 601 to 607 a capital asset type.

            Example:
              --entry category=907,user=1,debit-value=250
              --entry category=999,debit-value=-250,description="Suspense, to clear"
            """
    )

    @Option(name: .long, help: "Date of the entries (YYYY-MM-DD)")
    var datedOn: String

    @Option(name: .long, help: "Description")
    var description: String

    @Option(name: .long, help: "Tag identifying sets your tool creates - tagged sets are read-only in FreeAgent")
    var tag: String?

    @Option(name: .long, help: ArgumentHelp(JournalEntryArgument.help), transform: JournalEntryArgument.init)
    var entry: [JournalEntryArgument]

    @Flag(help: "Print the request instead of sending it")
    var dryRun = false

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func perform(client: Client) async throws -> Components.Schemas.JournalSetResponse {
        let journalSetPayload = Components.Schemas.JournalSetCreatePayload(
            datedOn: datedOn,
            description: description,
            tag: tag,
            journalEntries: entry.map(\.payload)
        )

        let input = Operations.CreateJournalSet.Input(
            body: .json(.init(journalSet: journalSetPayload))
        )

        return try await client.createJournalSet(input)
            .created.body.json
    }

    func success(for response: Components.Schemas.JournalSetResponse) -> String {
        "Created journal set \(response.journalSet.url)"
    }
}
