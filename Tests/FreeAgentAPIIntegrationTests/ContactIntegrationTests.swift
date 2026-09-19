import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("contacts")))
struct ContactIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/contacts returns a list of contacts")
    func listContacts() async throws {
        let response = try await client.listContacts(.init())
        let contacts = try response.ok.body.json.contacts

        #expect(!contacts.isEmpty)

        let contact = try #require(contacts.first)
        #expect(contact.url.contains("/v2/contacts/"))
        #expect(contact.status == .active)
        #expect(contact.createdAt <= Date())
        #expect(contact.updatedAt <= Date())
    }

    @Test("POST /v2/contacts creates a contact and GET /v2/contacts returns it")
    func createContact() async throws {
        let payload = Components.Schemas.ContactCreatePayload(
            organisationName: "Integration Test Ltd"
        )
        let createInput = Operations.CreateContact.Input(
            body: .json(.init(contact: payload))
        )

        let createResponse = try await client.createContact(createInput)
        let created = try createResponse.created.body.json.contact

        #expect(created.url.contains("/v2/contacts/"))
        #expect(created.organisationName == "Integration Test Ltd")
        #expect(created.status == .active)
        #expect(abs(created.createdAt.timeIntervalSinceNow) < 5)
        #expect(abs(created.updatedAt.timeIntervalSinceNow) < 5)
    }

    @Test("POST /v2/contacts reports every reason FreeAgent rejected the contact")
    func createContactReportsEveryValidationMessage() async throws {
        let payload = Components.Schemas.ContactCreatePayload(email: "notanemail")
        let input = Operations.CreateContact.Input(body: .json(.init(contact: payload)))

        do {
            _ = try await client.createContact(input)
            Issue.record("Expected FreeAgent to reject a contact with no name and an invalid email")
        } catch {
            let error = try #require(APIError.from(error))

            #expect(error.kind == .rejected)
            #expect(error.status == 422)
            #expect(error.messages.contains("email is not a valid email address"))
            #expect(error.messages.count > 1)
        }
    }

    // MARK: Private

    private let client: Client

}
