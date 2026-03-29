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
        #expect(contact.status == .Active)
        #expect(!contact.createdAt.isEmpty)
        #expect(!contact.updatedAt.isEmpty)
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
        #expect(created.status == .Active)
        #expect(!created.createdAt.isEmpty)
        #expect(!created.updatedAt.isEmpty)
    }

    // MARK: Private

    private let client: Client

}
