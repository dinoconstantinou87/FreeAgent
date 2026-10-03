import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("projects")))
struct ProjectIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/projects returns a typed, counted list filtered by contact")
    func listProjects() async throws {
        let ok = try await client.listProjects(.init(query: .init(view: .all, sort: ._hyphen_contactName))).ok
        let projects = try ok.body.json.projects

        #expect(ok.headers.xTotalCount != nil)
        #expect(projects.allSatisfy { $0.url.contains("/v2/projects/") })

        let contact = try #require(projects.first?.contact)
        let byContact = try await client.listProjects(.init(query: .init(contact: Self.id(of: contact)))).ok.body.json.projects

        #expect(!byContact.isEmpty)
        #expect(byContact.allSatisfy { $0.contact == contact })
    }

    @Test("A project can be created, updated, listed, shown and deleted")
    func projectLifecycle() async throws {
        let contact = try #require(
            try await client.listContacts(.init()).ok.body.json.contacts.first
        )
        let name = "ZZ Integration Test \(Int(Date().timeIntervalSince1970))"

        let created = try await client.createProject(
            .init(body: .json(.init(project: .init(
                contact: contact.url,
                name: name,
                status: .active,
                contractPoReference: "PO-IT",
                usesProjectInvoiceSequence: false,
                currency: .gbp,
                budget: 40,
                budgetUnits: .days,
                hoursPerDay: 7.5,
                normalBillingRate: 95,
                billingPeriod: .day,
                isIr35: false,
                startsOn: "2026-01-01",
                endsOn: "2026-12-31",
                includeUnbilledTimeInProfitability: true
            ))))
        ).created.body.json.project

        #expect(created.url.contains("/v2/projects/"))
        #expect(created.contact == contact.url)
        #expect(created.name == name)
        #expect(created.status == .active)
        #expect(created.contractPoReference == "PO-IT")
        #expect(created.budget == 40)
        #expect(created.budgetUnits == .days)
        #expect(created.hoursPerDay == "7.5")
        #expect(created.normalBillingRate == "95.0")
        #expect(created.billingPeriod == .day)
        #expect(created.isIr35 == false)
        #expect(created.startsOn == "2026-01-01")
        #expect(created.endsOn == "2026-12-31")

        let id = Self.id(of: created.url)

        let updated = try await client.updateProject(
            .init(path: .init(id: id), body: .json(.init(project: .init(
                status: .completed,
                budgetUnits: .monetary,
                billingPeriod: .hour
            ))))
        ).ok.body.json.project

        #expect(updated.url == created.url)
        #expect(updated.status == .completed)
        #expect(updated.budgetUnits == .monetary)
        #expect(updated.billingPeriod == .hour)

        _ = try await client.listProjects(
            .init(query: .init(view: .completed, sort: ._hyphen_createdAt, contact: Self.id(of: contact.url)))
        ).ok.body.json.projects

        let shown = try await client.showProject(.init(path: .init(id: id))).ok.body.json.project
        #expect(shown.url == created.url)
        #expect(shown.isDeletable != nil)

        _ = try await client.deleteProject(.init(path: .init(id: id))).ok
    }

    // MARK: Private

    private let client: Client

    private static func id(of url: String) -> String {
        String(url.split(separator: "/").last ?? "")
    }

}
