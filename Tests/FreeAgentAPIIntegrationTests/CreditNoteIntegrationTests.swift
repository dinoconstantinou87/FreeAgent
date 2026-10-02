import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.serialized, .enabled(if: IntegrationTest.isModelEnabled("credit_notes")))
struct CreditNoteIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/credit_notes returns a typed, counted list")
    func listCreditNotes() async throws {
        let ok = try await client.listCreditNotes(.init(query: .init(nestedCreditNoteItems: true))).ok
        let creditNotes = try ok.body.json.creditNotes

        #expect(ok.headers.xTotalCount != nil)
        #expect(creditNotes.allSatisfy { $0.url.contains("/v2/credit_notes/") })
        #expect(creditNotes.allSatisfy { $0.creditNoteItems != nil })
    }

    @Test("A credit note can be itemised, updated, listed, sent, saved as a PDF and deleted")
    func creditNoteLifecycle() async throws {
        let contact = try #require(
            try await client.listContacts(.init()).ok.body.json.contacts.first
        )

        let created = try await client.createCreditNote(
            .init(body: .json(.init(creditNote: .init(
                contact: Self.id(of: contact.url),
                datedOn: Self.today,
                paymentTermsInDays: 30
            ))))
        ).created.body.json.creditNote

        #expect(created.url.contains("/v2/credit_notes/"))
        #expect(created.contact == contact.url)
        #expect(created.status == "Draft")
        #expect(created.paymentTermsInDays == 30)
        #expect(created.reference != nil)

        let id = Self.id(of: created.url)

        let unsendable = await #expect(throws: (any Error).self) {
            try await client.markCreditNoteAsSent(.init(path: .init(id: id))).ok
        }
        #expect(unsendable.flatMap(APIError.from)?.status == 403)

        let itemised = try await client.updateCreditNote(
            .init(path: .init(id: id), body: .json(.init(creditNote: .init(creditNoteItems: [
                .init(description: "Integration test refund", itemType: .hours, price: -95, quantity: 2),
                .init(description: "Integration test comment", itemType: .comment, price: 0, quantity: 0),
            ]))))
        ).ok.body.json.creditNote

        let items = try #require(itemised.creditNoteItems)
        #expect(items.count == 2)

        let refund = try #require(items.first)
        #expect(refund.url.contains("/v2/invoice_items/"))
        #expect(refund.price == "-95.0")
        #expect(refund.salesTaxRate == "20.0")

        let comment = try #require(items.last)

        let revised = try await client.updateCreditNote(
            .init(path: .init(id: id), body: .json(.init(creditNote: .init(creditNoteItems: [
                .init(id: Self.id(of: refund.url), description: "Integration test refund, revised", itemType: .hours),
                .init(id: Self.id(of: comment.url), _destroy: 1),
            ]))))
        ).ok.body.json.creditNote

        #expect(revised.creditNoteItems?.map(\.url) == [refund.url])
        #expect(revised.creditNoteItems?.first?.description == "Integration test refund, revised")
        #expect(revised.creditNoteItems?.first?.itemType == "Hours")
        #expect(revised.creditNoteItems?.first?.price == "-95.0")

        let reference = "IT-CN-\(Int(Date().timeIntervalSince1970))"
        let updated = try await client.updateCreditNote(
            .init(path: .init(id: id), body: .json(.init(creditNote: .init(reference: reference, comments: "Integration test"))))
        ).ok.body.json.creditNote

        #expect(updated.reference == reference)
        #expect(updated.comments == "Integration test")

        let byContact = try await client.listCreditNotes(
            .init(query: .init(nestedCreditNoteItems: true, contact: Self.id(of: contact.url), view: .named(.draft)))
        ).ok.body.json.creditNotes
        let listed = try #require(byContact.first { $0.url == created.url })
        #expect(listed.creditNoteItems?.map(\.url) == [refund.url])

        let lastMonth = try await client.listCreditNotes(.init(query: .init(view: .lastMonths(1)))).ok.body.json.creditNotes
        #expect(lastMonth.map(\.url).contains(created.url))

        let shown = try await client.showCreditNote(.init(path: .init(id: id))).ok.body.json.creditNote
        #expect(shown.url == created.url)
        #expect(shown.reference == reference)
        #expect(shown.creditNoteItems?.map(\.url) == [refund.url])

        let content = try #require(
            try await client.showCreditNoteAsPdf(.init(path: .init(id: id))).ok.body.json.pdf.content
        )
        #expect(Data(base64Encoded: content, options: .ignoreUnknownCharacters) != nil)

        let sent = try await client.markCreditNoteAsSent(.init(path: .init(id: id))).ok.body.json.creditNote
        #expect(sent.status == "Open")

        let refused = await #expect(throws: (any Error).self) {
            try await client.deleteCreditNote(.init(path: .init(id: id))).ok
        }
        #expect(refused.flatMap(APIError.from)?.status == 409)

        let draft = try await client.markCreditNoteAsDraft(.init(path: .init(id: id))).ok.body.json.creditNote
        #expect(draft.status == "Draft")

        _ = try await client.deleteCreditNote(.init(path: .init(id: id))).ok
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

}
