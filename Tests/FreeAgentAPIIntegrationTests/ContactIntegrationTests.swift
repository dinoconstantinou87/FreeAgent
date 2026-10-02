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

    @Test("GET /v2/contacts returns a typed, counted list")
    func listContacts() async throws {
        let ok = try await client.listContacts(.init(query: .init(view: .all, sort: ._hyphen_updatedAt))).ok
        let contacts = try ok.body.json.contacts

        #expect(ok.headers.xTotalCount != nil)
        #expect(!contacts.isEmpty)
        #expect(contacts.allSatisfy { $0.url.contains("/v2/contacts/") })
        #expect(contacts.allSatisfy { $0.createdAt <= Date() && $0.updatedAt <= Date() })
    }

    @Test("A contact can be created, updated, listed, shown and deleted")
    func contactLifecycle() async throws {
        let name = "ZZ Integration Test \(Int(Date().timeIntervalSince1970))"

        let created = try await client.createContact(
            .init(body: .json(.init(contact: .init(
                organisationName: name,
                firstName: "Ada",
                lastName: "Lovelace",
                email: "ada@example.com",
                town: "London",
                defaultPaymentTermsInDays: 14,
                locale: .fr,
                chargeSalesTax: .never,
                usesContactInvoiceSequence: true
            ))))
        ).created.body.json.contact

        #expect(created.url.contains("/v2/contacts/"))
        #expect(created.organisationName == name)
        #expect(created.firstName == "Ada")
        #expect(created.email == "ada@example.com")
        #expect(created.locale == "fr")
        #expect(created.chargeSalesTax == "Never")
        #expect(created.defaultPaymentTermsInDays == 14)
        #expect(created.usesContactInvoiceSequence == true)

        let id = Self.id(of: created.url)

        let updated = try await client.updateContact(
            .init(path: .init(id: id), body: .json(.init(contact: .init(town: "Manchester", status: .hidden))))
        ).ok.body.json.contact

        #expect(updated.url == created.url)
        #expect(updated.town == "Manchester")
        #expect(updated.status == .hidden)

        _ = try await client.listContacts(
            .init(query: .init(view: .hidden, sort: ._hyphen_createdAt, updatedSince: Self.timestamp(of: created.createdAt)))
        ).ok.body.json.contacts

        let shown = try await client.showContact(.init(path: .init(id: id))).ok.body.json.contact
        #expect(shown.url == created.url)

        _ = try await client.deleteContact(.init(path: .init(id: id))).ok
    }

    @Test("A rejected contact's errors decode as a list of messages")
    func rejectedContactDecodesErrorList() async throws {
        let payload = Components.Schemas.ContactCreatePayload(email: "notanemail")
        let input = Operations.CreateContact.Input(body: .json(.init(contact: payload)))

        do {
            _ = try await client.createContact(input)
            Issue.record("Expected FreeAgent to reject a contact with no name and an invalid email")
        } catch {
            let error = try #require(APIError.from(error))

            #expect(error.messages.count > 1)
        }
    }

    // MARK: Private

    private let client: Client

    private static func id(of url: String) -> String {
        String(url.split(separator: "/").last ?? "")
    }

    private static func timestamp(of date: Date) -> String {
        date.addingTimeInterval(-1).ISO8601Format()
    }

}
