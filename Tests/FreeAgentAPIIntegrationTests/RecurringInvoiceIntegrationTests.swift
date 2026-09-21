import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("recurring_invoices")))
struct RecurringInvoiceIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/recurring_invoices returns a typed list")
    func listRecurringInvoices() async throws {
        let profiles = try await client.listAllRecurringInvoices(.init())
            .ok.body.json.recurringInvoices

        #expect(!profiles.isEmpty)

        let profile = try #require(profiles.first)
        #expect(profile.url.contains("/v2/recurring_invoices/"))
        #expect(try #require(profile.contact).contains("/v2/contacts/"))
        #expect(profile.frequency != nil)
        #expect(profile.recurringStatus != nil)
        #expect(profile.profileId != nil)
        #expect(profile.nextRecursOn != nil)
        #expect(profile.paymentTermsInDays != nil)
        #expect(profile.totalValue != nil)
        #expect(profile.isInterimUkVat != nil)
        #expect(try #require(profile.createdAt) <= Date())
    }

    @Test("GET /v2/recurring_invoices/:id returns a typed profile with its items")
    func showRecurringInvoice() async throws {
        let listed = try #require(
            try await client.listAllRecurringInvoices(.init()).ok.body.json.recurringInvoices.first
        )
        let id = String(listed.url.split(separator: "/").last ?? "")

        let profile = try await client.showRecurringInvoice(.init(path: .init(id: id)))
            .ok.body.json.recurringInvoice

        #expect(profile.url == listed.url)
        #expect(profile.reference == listed.reference)
        #expect(profile.totalValue == listed.totalValue)

        let item = try #require(profile.recurringInvoiceItems?.first)
        #expect(item.url.contains("/v2/recurring_invoice_items/"))
        #expect(item.position != nil)
        #expect(item.price != nil)
        #expect(item.itemType != nil)
        #expect(item.suffersCisDeduction != nil)
    }

    // MARK: Private

    private let client: Client

}
