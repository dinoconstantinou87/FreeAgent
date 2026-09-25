import Noora
import Testing

@testable import FreeAgentCLI

struct NoorablePaginatedTableTests {

    // MARK: Internal

    @Test("renders the first page from what was already fetched")
    func rendersFirstPageWithoutFetching() async throws {
        try await ui.paginatedTable(
            noun: "invoices",
            headers: ["Reference"],
            page: 2,
            pageSize: 10,
            firstPage: (["INV-011", "INV-012"], 25),
            row: { [$0] },
            fetch: { page in
                Issue.record("fetched page \(page) again")
                return []
            }
        )

        #expect(ui.description.contains("INV-011"))
        #expect(ui.description.contains("INV-012"))
    }

    @Test("says nothing was found when the first page is empty")
    func reportsEmptyFirstPage() async throws {
        try await ui.paginatedTable(
            noun: "invoices",
            headers: ["Reference"],
            page: 1,
            pageSize: 10,
            firstPage: ([String](), 0),
            row: { [$0] },
            fetch: { _ in [] }
        )

        #expect(ui.description == "No invoices found\n")
    }

    @Test("names the page when a later page is empty")
    func reportsEmptyLaterPage() async throws {
        try await ui.paginatedTable(
            noun: "invoices",
            headers: ["Reference"],
            page: 3,
            pageSize: 10,
            firstPage: ([String](), 12),
            row: { [$0] },
            fetch: { _ in [] }
        )

        #expect(ui.description == "No invoices found on page 3\n")
    }

    @Test(
        "counts pages from the total",
        arguments: [(25, 10, 3), (20, 10, 2), (1, 10, 1), (100, 100, 1), (101, 100, 2)]
    )
    func countsPages(totalCount: Int, pageSize: Int, pageCount: Int) {
        #expect(Noora.pageCount(totalCount: totalCount, pageSize: pageSize) == pageCount)
    }

    @Test("treats a missing total as a single page")
    func countsMissingTotalAsOnePage() {
        #expect(Noora.pageCount(totalCount: nil, pageSize: 10) == 1)
    }

    // MARK: Private

    private let ui = NooraMock(terminal: Terminal(isInteractive: false, isColored: false, signalBehavior: .none))

}
