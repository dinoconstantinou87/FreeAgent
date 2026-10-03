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

    @Test("PUT /v2/users/me returns the updated user the token belongs to")
    func updateCurrentUser() async throws {
        let user = try await client.showCurrentUser(.init()).ok.body.json.user

        let updated = try await client.updateCurrentUser(
            .init(body: .json(.init(user: .init(firstName: user.firstName))))
        ).ok.body.json.user

        #expect(updated.url == user.url)
        #expect(updated.firstName == user.firstName)
    }

    @Test("GET /v2/users returns a typed, counted list")
    func listUsers() async throws {
        let ok = try await client.listUsers(.init(query: .init(view: .activeStaff))).ok
        let users = try ok.body.json.users

        #expect(ok.headers.xTotalCount != nil)
        #expect(users.allSatisfy { $0.url.contains("/v2/users/") })
    }

    @Test("A user can be created, updated, listed, shown and deleted")
    func userLifecycle() async throws {
        let email = "integration-test-\(Int(Date().timeIntervalSince1970))@example.com"

        let created = try await client.createUser(
            .init(body: .json(.init(user: .init(
                email: email,
                firstName: "Integration",
                lastName: "Test",
                role: .employee,
                permissionLevel: 1,
                niNumber: "AB123456C",
                uniqueTaxReference: "1234567890",
                openingMileage: 120.5,
                hidden: false,
                sendInvitation: false
            ))))
        ).created.body.json.user

        #expect(created.url.contains("/v2/users/"))
        #expect(created.email == email)
        #expect(created.firstName == "Integration")
        #expect(created.lastName == "Test")
        #expect(created.role == "Employee")
        #expect(created.permissionLevel == 1)
        #expect(created.niNumber == "AB123456C")
        #expect(created.uniqueTaxReference == "1234567890")
        #expect(created.openingMileage == "120.5")
        #expect(created.hidden == false)

        let id = Self.id(of: created.url)

        let updated = try await client.updateUser(
            .init(path: .init(id: id), body: .json(.init(user: .init(
                lastName: "Updated",
                role: .accountant,
                permissionLevel: 7,
                hidden: true
            ))))
        ).ok.body.json.user

        #expect(updated.url == created.url)
        #expect(updated.lastName == "Updated")
        #expect(updated.role == "Accountant")
        #expect(updated.permissionLevel == 7)
        #expect(updated.hidden == true)

        _ = try await client.listUsers(.init(query: .init(view: .advisors))).ok.body.json.users

        let shown = try await client.showUser(.init(path: .init(id: id))).ok.body.json.user
        #expect(shown.url == created.url)

        _ = try await client.deleteUser(.init(path: .init(id: id))).ok
    }

    // MARK: Private

    private let client: Client

    private static func id(of url: String) -> String {
        String(url.split(separator: "/").last ?? "")
    }

}
