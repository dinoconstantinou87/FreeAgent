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
        let ok = try await client.listTasks(.init()).ok
        let tasks = try ok.body.json.tasks

        #expect(ok.headers.xTotalCount != nil)
        #expect(tasks.allSatisfy { $0.url.contains("/v2/tasks/") })

        let project = try #require(tasks.first?.project)
        let byProject = try await client.listTasks(.init(query: .init(project: Self.id(of: project)))).ok.body.json.tasks

        #expect(!byProject.isEmpty)
        #expect(byProject.allSatisfy { $0.project == project })
    }

    // MARK: Private

    private let client: Client

    private static func id(of url: String) -> String {
        String(url.split(separator: "/").last ?? "")
    }

}
