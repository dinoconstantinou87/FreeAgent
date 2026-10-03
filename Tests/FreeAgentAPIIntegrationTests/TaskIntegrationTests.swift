import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("tasks")))
struct TaskIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/tasks returns a typed, counted list filtered by project")
    func listTasks() async throws {
        let ok = try await client.listTasks(.init(query: .init(
            view: .all,
            sort: ._hyphen_billingRate,
            updatedSince: "2025-01-01"
        ))).ok
        let tasks = try ok.body.json.tasks

        #expect(ok.headers.xTotalCount != nil)
        #expect(tasks.allSatisfy { $0.url.contains("/v2/tasks/") })

        let project = try #require(tasks.first?.project)
        let byProject = try await client.listTasks(.init(query: .init(project: Self.id(of: project)))).ok.body.json.tasks

        #expect(!byProject.isEmpty)
        #expect(byProject.allSatisfy { $0.project == project })
    }

    @Test("A task can be created, updated, listed, shown and deleted")
    func taskLifecycle() async throws {
        let project = try #require(
            try await client.listProjects(.init(query: .init(view: .active))).ok.body.json.projects.first
        )
        let name = "ZZ Integration Test \(Int(Date().timeIntervalSince1970))"

        let created = try await client.createTask(
            .init(
                query: .init(project: Self.id(of: project.url)),
                body: .json(.init(task: .init(
                    name: name,
                    isBillable: false,
                    billingRate: 42.5,
                    billingPeriod: .day,
                    status: .active
                )))
            )
        ).created.body.json.task

        #expect(created.url.contains("/v2/tasks/"))
        #expect(created.project == project.url)
        #expect(created.name == name)
        #expect(created.isBillable == false)
        #expect(created.billingRate == "42.5")
        #expect(created.billingPeriod == .day)
        #expect(created.status == .active)

        let id = Self.id(of: created.url)

        let updated = try await client.updateTask(
            .init(path: .init(id: id), body: .json(.init(task: .init(
                name: name + " Updated",
                isBillable: true,
                billingRate: 50,
                billingPeriod: .hour,
                status: .completed
            ))))
        ).ok.body.json.task

        #expect(updated.url == created.url)
        #expect(updated.name == name + " Updated")
        #expect(updated.isBillable == true)
        #expect(updated.billingRate == "50.0")
        #expect(updated.billingPeriod == .hour)
        #expect(updated.status == .completed)

        _ = try await client.listTasks(
            .init(query: .init(view: .completed, sort: .name, project: Self.id(of: project.url)))
        ).ok.body.json.tasks

        let shown = try await client.showTask(.init(path: .init(id: id))).ok.body.json.task
        #expect(shown.url == created.url)
        #expect(shown.isDeletable != nil)

        _ = try await client.deleteTask(.init(path: .init(id: id))).ok
    }

    // MARK: Private

    private let client: Client

    private static func id(of url: String) -> String {
        String(url.split(separator: "/").last ?? "")
    }

}
