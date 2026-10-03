import ArgumentParser
import Foundation
import FreeAgentAPI

struct JournalSetListCommand: AsyncPaginatedListCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List journal sets",
        discussion: "Sets are listed by date, with the undated opening balances set first."
    )

    static let noun = "journal sets"

    static var columns: [Field<Components.Schemas.JournalSet>] {
        Field("ID") { .id(url: $0.url) }
        Field("Dated On") { .date($0.datedOn) }
        Field("Description") { .text($0.description) }
        Field("Tag") { .text($0.tag) }
        Field("Entries") { .number($0.journalEntries?.count) }
    }

    @Option(name: .long, help: "Show journal sets dated on or after this date (YYYY-MM-DD)")
    var fromDate: String?

    @Option(name: .long, help: "Show journal sets dated on or before this date (YYYY-MM-DD)")
    var toDate: String?

    @Option(name: .long, help: "Show journal sets updated since this date or timestamp")
    var updatedSince: String?

    @Option(name: .long, help: "Filter by tag, ignoring case")
    var tag: String?

    @OptionGroup var pagination: PaginationOptions

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(
        client: Client,
        page: Int
    ) async throws -> (response: Components.Schemas.JournalSetListResponse, totalCount: Int?) {
        let ok = try await client.listJournalSets(
            .init(query: .init(
                fromDate: fromDate,
                toDate: toDate,
                updatedSince: updatedSince,
                tag: tag,
                page: page,
                perPage: pagination.size
            ))
        ).ok

        return (try ok.body.json, ok.headers.xTotalCount)
    }

    func items(in response: Components.Schemas.JournalSetListResponse) -> [Components.Schemas.JournalSet] {
        response.journalSets
    }
}
