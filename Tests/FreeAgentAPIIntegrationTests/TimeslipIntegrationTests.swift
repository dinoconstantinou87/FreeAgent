import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.serialized, .enabled(if: IntegrationTest.isModelEnabled("timeslips")))
struct TimeslipIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/timeslips returns a typed, counted list")
    func listTimeslips() async throws {
        let ok = try await client.listTimeslips(.init(query: .init(view: .all, sort: ._hyphen_datedOn))).ok
        let timeslips = try ok.body.json.timeslips

        #expect(ok.headers.xTotalCount != nil)
        #expect(timeslips.allSatisfy { $0.url.contains("/v2/timeslips/") })
        #expect(timeslips.allSatisfy { $0.task != nil && $0.project != nil && $0.user != nil })
    }

    @Test("A timeslip can be created, updated, listed, timed and deleted")
    func timeslipLifecycle() async throws {
        let existing = try #require(
            try await client.listTimeslips(.init(query: .init(perPage: 1))).ok.body.json.timeslips.first
        )
        let task = try #require(existing.task)
        let user = try await client.showCurrentUser(.init()).ok.body.json.user

        let created = try await client.createTimeslip(
            .init(body: .json(.init(timeslip: .init(
                user: Self.id(of: user.url),
                task: Self.id(of: task),
                datedOn: Self.today,
                hours: 1.5,
                comment: "Integration test"
            ))))
        ).created.body.json.timeslip

        #expect(created.url.contains("/v2/timeslips/"))
        #expect(created.user == user.url)
        #expect(created.task == task)
        #expect(created.hours == "1.5")
        #expect(created.comment == "Integration test")

        let id = Self.id(of: created.url)

        let updated = try await client.updateTimeslip(
            .init(path: .init(id: id), body: .json(.init(timeslip: .init(comment: "Integration test, revised"))))
        ).ok.body.json.timeslip

        #expect(updated.comment == "Integration test, revised")

        _ = try await client.listTimeslips(
            .init(query: .init(user: Self.id(of: user.url), task: Self.id(of: task), fromDate: Self.today, toDate: Self.today))
        ).ok.body.json.timeslips

        let started = try await client.startTimeslipTimer(.init(path: .init(id: id))).ok.body.json.timeslip
        #expect(started.timer?.startFrom != nil)

        _ = try await client.listTimeslips(.init(query: .init(view: .running))).ok.body.json.timeslips

        let stopped = try await client.stopTimeslipTimer(.init(path: .init(id: id))).ok.body.json.timeslip
        #expect(stopped.url == created.url)

        let shown = try await client.showTimeslip(.init(path: .init(id: id))).ok.body.json.timeslip
        #expect(shown.url == created.url)

        _ = try await client.deleteTimeslip(.init(path: .init(id: id))).ok
    }

    @Test("A timeslip billed through invoice create decodes the invoice that bills it")
    func billedTimeslip() async throws {
        let existing = try #require(
            try await client.listTimeslips(.init(query: .init(perPage: 1))).ok.body.json.timeslips.first
        )
        let task = try #require(existing.task)
        let project = try await client.showProject(
            .init(path: .init(id: Self.id(of: try #require(existing.project))))
        ).ok.body.json.project
        let contact = try #require(project.contact)
        let user = try await client.showCurrentUser(.init()).ok.body.json.user

        let timeslip = try await client.createTimeslip(
            .init(body: .json(.init(timeslip: .init(
                user: Self.id(of: user.url),
                task: Self.id(of: task),
                datedOn: Self.today,
                hours: 1,
                comment: "Integration test billing"
            ))))
        ).created.body.json.timeslip
        let id = Self.id(of: timeslip.url)

        let invoice = try await client.createInvoice(
            .init(body: .json(.init(invoice: .init(
                contact: Self.id(of: contact),
                project: Self.id(of: project.url),
                includeTimeslips: .billedGroupedByTimeslip,
                datedOn: Self.today,
                paymentTermsInDays: 30
            ))))
        ).created.body.json.invoice

        #expect(invoice.project == project.url)

        let billed = try await client.showTimeslip(.init(path: .init(id: id))).ok.body.json.timeslip
        #expect(billed.billedOnInvoice == invoice.url)

        _ = try await client.deleteInvoice(.init(path: .init(id: Self.id(of: invoice.url)))).ok
        _ = try await client.deleteTimeslip(.init(path: .init(id: id))).ok
    }

    // MARK: Private

    private static var today: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private let client: Client

    private static func id(of url: String) -> String {
        String(url.split(separator: "/").last ?? "")
    }

}
