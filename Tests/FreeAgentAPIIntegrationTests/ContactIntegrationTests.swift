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

    @Test("A contact can be created, updated, hidden, listed and deleted")
    func contactLifecycle() async throws {
        let name = "ZZ Integration Test \(Int(Date().timeIntervalSince1970))"

        let created = try await client.createContact(
            .init(body: .json(.init(contact: .init(
                organisationName: name,
                firstName: "Ada",
                lastName: "Lovelace",
                email: "ada@example.com",
                town: "London",
                region: "Greater London",
                defaultPaymentTermsInDays: 14,
                locale: .fr,
                chargeSalesTax: .never,
                usesContactInvoiceSequence: true
            ))))
        ).created.body.json.contact

        #expect(created.url.contains("/v2/contacts/"))
        #expect(created.organisationName == name)
        #expect(created.status == .active)
        #expect(created.locale == "fr")
        #expect(created.chargeSalesTax == "Never")
        #expect(created.defaultPaymentTermsInDays == 14)

        let id = Self.id(of: created.url)

        let updated = try await client.updateContact(
            .init(path: .init(id: id), body: .json(.init(contact: .init(town: "Manchester", region: ""))))
        ).ok.body.json.contact

        #expect(updated.town == "Manchester")
        #expect(updated.region == nil)
        #expect(updated.organisationName == name)
        #expect(updated.firstName == "Ada")
        #expect(updated.email == "ada@example.com")
        #expect(updated.defaultPaymentTermsInDays == 14)
        #expect(updated.locale == "fr")
        #expect(updated.chargeSalesTax == "Never")
        #expect(updated.usesContactInvoiceSequence == true)

        let hidden = try await client.updateContact(
            .init(path: .init(id: id), body: .json(.init(contact: .init(status: .hidden))))
        ).ok.body.json.contact
        #expect(hidden.status == .hidden)

        let hiddenView = try await client.listContacts(
            .init(query: .init(view: .hidden, perPage: 100))
        ).ok.body.json.contacts
        #expect(hiddenView.contains { $0.url == created.url })

        let recent = try await client.listContacts(
            .init(query: .init(view: .all, sort: ._hyphen_createdAt, updatedSince: Self.timestamp(of: created.createdAt)))
        ).ok.body.json.contacts
        #expect(recent.contains { $0.url == created.url })

        let shown = try await client.showContact(.init(path: .init(id: id))).ok.body.json.contact
        #expect(shown.url == created.url)
        #expect(shown.status == .hidden)
        #expect(shown.town == "Manchester")

        _ = try await client.deleteContact(.init(path: .init(id: id))).ok

        let missing = await #expect(throws: (any Error).self) {
            try await client.showContact(.init(path: .init(id: id))).ok
        }
        #expect(missing.flatMap(APIError.from)?.status == 404)
    }

    @Test("A contact with a bill is a 403 to delete, and only its bills list finds it, until the bill is deleted")
    func contactInUse() async throws {
        let contact = try await client.createContact(
            .init(
                body: .json(
                    .init(contact: .init(organisationName: "ZZ Integration Test In Use \(Int(Date().timeIntervalSince1970))"))
                )
            )
        ).created.body.json.contact
        let id = Self.id(of: contact.url)

        let bill = try await client.createBill(
            .init(body: .json(.init(bill: .init(
                contact: id,
                reference: "IT-CONTACT-\(Int(Date().timeIntervalSince1970))",
                datedOn: Self.today,
                dueOn: Self.today
            ))))
        ).created.body.json.bill

        let inUse = await #expect(throws: (any Error).self) {
            try await client.deleteContact(.init(path: .init(id: id))).ok
        }
        #expect(inUse.flatMap(APIError.from)?.status == 403)

        let bills = try await client.listBills(.init(query: .init(contact: id, perPage: 1))).ok.body.json.bills
        let invoices = try await client.listInvoices(.init(query: .init(contact: id, perPage: 1))).ok.body.json.invoices
        let estimates = try await client.listEstimates(.init(query: .init(contact: id, perPage: 1))).ok.body.json.estimates
        let projects = try await client.listProjects(.init(query: .init(contact: id, perPage: 1))).ok.body.json.projects
        #expect(bills.map(\.url) == [bill.url])
        #expect(invoices.isEmpty)
        #expect(estimates.isEmpty)
        #expect(projects.isEmpty)

        _ = try await client.deleteBill(.init(path: .init(id: Self.id(of: bill.url)))).ok
        _ = try await client.deleteContact(.init(path: .init(id: id))).ok
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

    private static var today: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private let client: Client

    private static func id(of url: String) -> String {
        String(url.split(separator: "/").last ?? "")
    }

    private static func timestamp(of date: Date) -> String {
        date.addingTimeInterval(-1).ISO8601Format()
    }

}
