import ArgumentParser
import Foundation
import FreeAgentAPI

struct JournalSetOpeningBalancesCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "opening-balances",
        abstract: "Show the opening balances journal set",
        discussion: "Its entries change through journal-set update with its ID; its date and description are locked."
    )

    static let title = "Opening Balances"

    static let sections = JournalSetShowCommand.sections

    static let tables = JournalSetShowCommand.tables

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.JournalSetResponse {
        try await client.showOpeningBalances().ok.body.json
    }

    func record(in response: Components.Schemas.JournalSetResponse) -> Components.Schemas.JournalSet {
        response.journalSet
    }
}
