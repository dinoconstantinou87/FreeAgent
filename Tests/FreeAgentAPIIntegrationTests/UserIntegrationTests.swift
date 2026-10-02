import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("users")))
struct UserIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/users/me returns the user the token belongs to")
    func showCurrentUser() async throws {
        let user = try await client.showCurrentUser(.init()).ok.body.json.user

        #expect(user.url.contains("/v2/users/"))
        #expect(user.firstName != nil)
        #expect(user.lastName != nil)
        #expect(user.email != nil)
        #expect(user.role != nil)
        #expect(user.permissionLevel != nil)
        #expect(user.openingMileage != nil)
        #expect(user.hidden != nil)
        #expect(user.createdAt != nil)
        #expect(user.updatedAt != nil)
    }

    // MARK: Private

    private let client: Client

}
