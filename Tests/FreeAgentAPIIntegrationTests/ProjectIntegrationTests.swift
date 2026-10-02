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
        let ok = try await client.listProjects(.init()).ok
        let projects = try ok.body.json.projects

        #expect(ok.headers.xTotalCount != nil)
        #expect(projects.allSatisfy { $0.url.contains("/v2/projects/") })

        let contact = try #require(projects.first?.contact)
        let byContact = try await client.listProjects(.init(query: .init(contact: Self.id(of: contact)))).ok.body.json.projects

        #expect(!byContact.isEmpty)
        #expect(byContact.allSatisfy { $0.contact == contact })
    }

    // MARK: Private

    private let client: Client

    private static func id(of url: String) -> String {
        String(url.split(separator: "/").last ?? "")
    }

}
