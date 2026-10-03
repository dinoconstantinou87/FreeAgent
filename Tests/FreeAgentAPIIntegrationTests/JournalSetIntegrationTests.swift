import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("journal_sets")))
struct JournalSetIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/journal_sets returns a typed, counted list")
    func listJournalSets() async throws {
        let ok = try await client.listJournalSets(.init(query: .init(
            fromDate: "2025-01-01",
            toDate: "2030-12-31",
            updatedSince: "2025-01-01",
            tag: "INTEGRATIONTEST"
        ))).ok
        let journalSets = try ok.body.json.journalSets

        #expect(ok.headers.xTotalCount != nil)
        #expect(journalSets.allSatisfy { $0.url.contains("/v2/journal_sets/") })
    }

    @Test("GET /v2/journal_sets/opening_balances returns the typed opening balances set")
    func showOpeningBalances() async throws {
        let openingBalances = try await client.showOpeningBalances().ok.body.json.journalSet

        #expect(openingBalances.url.contains("/v2/journal_sets/"))
        #expect(openingBalances.bankAccounts != nil)
        #expect(openingBalances.stockItems != nil)
    }

    @Test("A journal set can be created, updated, listed, shown and deleted")
    func journalSetLifecycle() async throws {
        let user = try await client.showCurrentUser(.init()).ok.body.json.user
        let description = "ZZ Integration Test \(Int(Date().timeIntervalSince1970))"

        let created = try await client.createJournalSet(
            .init(body: .json(.init(journalSet: .init(
                datedOn: "2026-09-30",
                description: description,
                tag: "INTEGRATIONTEST",
                journalEntries: [
                    .init(category: "901", debitValue: 25.5, description: "Capital", user: Self.id(of: user.url)),
                    .init(category: "280", debitValue: 4.5),
                    .init(category: "999", debitValue: -30, description: "Suspense"),
                ]
            ))))
        ).created.body.json.journalSet

        #expect(created.url.contains("/v2/journal_sets/"))
        #expect(created.datedOn == "2026-09-30")
        #expect(created.description == description)
        #expect(created.tag == "INTEGRATIONTEST")

        let entries = try #require(created.journalEntries)
        #expect(Set(entries.compactMap(\.debitValue)) == ["25.5", "4.5", "-30.0"])
        #expect(entries.allSatisfy { $0.url.contains("/journal_entries/") })
        #expect(entries.contains { $0.user == user.url })

        let id = Self.id(of: created.url)
        let sundries = try #require(entries.first { $0.debitValue == "4.5" })
        let suspense = try #require(entries.first { $0.debitValue == "-30.0" })

        let updated = try await client.updateJournalSet(
            .init(path: .init(id: id), body: .json(.init(journalSet: .init(
                datedOn: "2026-09-29",
                description: description + " Updated",
                tag: "INTEGRATIONTEST2",
                journalEntries: [
                    .init(url: sundries.url, _destroy: true),
                    .init(url: suspense.url, debitValue: -25.5),
                ]
            ))))
        ).ok.body.json.journalSet

        #expect(updated.url == created.url)
        #expect(updated.datedOn == "2026-09-29")
        #expect(updated.description == description + " Updated")
        #expect(updated.tag == "INTEGRATIONTEST2")
        #expect(Set(updated.journalEntries?.map(\.url) ?? []) == Set(entries.map(\.url)).subtracting([sundries.url]))

        _ = try await client.listJournalSets(.init(query: .init(tag: "INTEGRATIONTEST2"))).ok.body.json.journalSets

        let shown = try await client.showJournalSet(.init(path: .init(id: id))).ok.body.json.journalSet
        #expect(shown.url == created.url)

        _ = try await client.deleteJournalSet(.init(path: .init(id: id))).ok
    }

    // MARK: Private

    private let client: Client

    private static func id(of url: String) -> String {
        String(url.split(separator: "/").last ?? "")
    }

}
