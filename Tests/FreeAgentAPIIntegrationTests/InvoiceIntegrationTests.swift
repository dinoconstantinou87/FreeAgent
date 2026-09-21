import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("invoices")))
struct InvoiceIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/invoices returns a typed list with nested items")
    func listInvoices() async throws {
        let invoices = try await client.listInvoices(.init(query: .init(nestedInvoiceItems: true)))
            .ok.body.json.invoices

        #expect(!invoices.isEmpty)

        let invoice = try #require(invoices.first)
        #expect(invoice.url.contains("/v2/invoices/"))
        #expect(try #require(invoice.contact).contains("/v2/contacts/"))
        #expect(invoice.status != nil)
        #expect(invoice.paymentTermsInDays != nil)
        #expect(invoice.totalValue != nil)
        #expect(invoice.createdAt != nil)

        let items = invoices.compactMap(\.invoiceItems).flatMap { $0 }
        let item = try #require(items.first)
        #expect(item.url.contains("/v2/invoice_items/"))
        #expect(item.position != nil)
        #expect(item.price != nil)
        #expect(item.suffersCisDeduction != nil)
    }

    @Test("GET /v2/invoices/:id returns a typed invoice")
    func showInvoice() async throws {
        let listed = try #require(
            try await client.listInvoices(.init()).ok.body.json.invoices.first
        )
        let id = String(listed.url.split(separator: "/").last ?? "")

        let invoice = try await client.showInvoice(.init(path: .init(id: id)))
            .ok.body.json.invoice

        #expect(invoice.url == listed.url)
        #expect(invoice.reference == listed.reference)
        #expect(invoice.totalValue == listed.totalValue)
    }

    @Test("GET /v2/invoices/timeline returns a typed timeline")
    func invoiceTimeline() async throws {
        let timeline = try await client.getInvoiceTimeline(.init())
            .ok.body.json

        #expect(timeline.invoiceTimelineItems.allSatisfy { $0.datedOn != nil || $0.summary != nil })
    }

    @Test("GET /v2/invoices/:id/pdf returns base64 content")
    func invoicePdf() async throws {
        let listed = try #require(
            try await client.listInvoices(.init()).ok.body.json.invoices.first
        )
        let id = String(listed.url.split(separator: "/").last ?? "")

        let content = try #require(
            try await client.showInvoiceAsPdf(.init(path: .init(id: id))).ok.body.json.pdf.content
        )

        #expect(!content.isEmpty)
        #expect(Data(base64Encoded: content, options: .ignoreUnknownCharacters) != nil)
    }

    @Test("An invoice can be created, itemised, updated and transitioned")
    func invoiceLifecycle() async throws {
        let contact = try #require(
            try await client.listContacts(.init()).ok.body.json.contacts.first
        )

        let created = try await client.createInvoice(
            .init(body: .json(.init(invoice: .init(
                contact: contact.url,
                datedOn: Self.ninetyDaysAgo,
                paymentTermsInDays: 30
            ))))
        ).created.body.json.invoice

        #expect(created.url.contains("/v2/invoices/"))
        #expect(created.contact == contact.url)
        #expect(created.status == "Draft")

        let id = String(created.url.split(separator: "/").last ?? "")

        let item = try await client.createInvoiceItem(
            .init(body: .json(.init(
                invoice: created.url,
                invoiceItem: .init(
                    description: "Integration test item",
                    itemType: .hours,
                    price: 95,
                    quantity: 2
                )
            )))
        ).created.body.json.invoiceItem

        #expect(item.url.contains("/v2/invoice_items/"))
        #expect(item.description == "Integration test item")
        #expect(item.price == "95.0")

        let itemId = String(item.url.split(separator: "/").last ?? "")
        let updatedItem = try await client.updateInvoiceItem(
            .init(path: .init(id: itemId), body: .json(.init(invoiceItem: .init(
                description: "Integration test item, revised"
            ))))
        ).ok.body.json.invoiceItem

        #expect(updatedItem.description == "Integration test item, revised")

        let updated = try await client.updateInvoice(
            .init(path: .init(id: id), body: .json(.init(invoice: .init(notes: "Integration test"))))
        ).ok.body.json.invoice

        #expect(updated.url == created.url)

        let sent = try await client.markInvoiceAsSent(.init(path: .init(id: id)))
            .ok.body.json.invoice
        #expect(sent.status == "Overdue")
        #expect(sent.dueOn != nil)

        let writtenOff = try await client.markInvoiceAsCancelled(.init(path: .init(id: id)))
            .ok.body.json.invoice
        #expect(writtenOff.status == "Written-off")

        let reopened = try await client.markInvoiceAsSent(.init(path: .init(id: id)))
            .ok.body.json.invoice
        #expect(reopened.status == "Overdue")

        let draft = try await client.markInvoiceAsDraft(.init(path: .init(id: id)))
            .ok.body.json.invoice
        #expect(draft.status == "Draft")
    }

    // MARK: Private

    private static var ninetyDaysAgo: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date().addingTimeInterval(-90 * 24 * 60 * 60))
    }

    private let client: Client

}
