import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.serialized, .enabled(if: IntegrationTest.isModelEnabled("estimates")))
struct EstimateIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/estimates returns a typed, counted list with nested items")
    func listEstimates() async throws {
        let ok = try await client.listEstimates(.init(query: .init(nestedEstimateItems: true))).ok
        let estimates = try ok.body.json.estimates

        #expect(!estimates.isEmpty)
        #expect(ok.headers.xTotalCount != nil)

        let estimate = try #require(estimates.first)
        #expect(estimate.url.contains("/v2/estimates/"))
        #expect(try #require(estimate.contact).contains("/v2/contacts/"))
        #expect(estimate.status != nil)
        #expect(estimate.estimateType != nil)
        #expect(estimate.datedOn != nil)
        #expect(estimate.totalValue != nil)
        #expect(estimate.estimateItems != nil)
    }

    @Test("GET /v2/estimates/:id returns a typed estimate")
    func showEstimate() async throws {
        let listed = try #require(
            try await client.listEstimates(.init()).ok.body.json.estimates.first
        )

        let estimate = try await client.showEstimate(.init(path: .init(id: Self.id(of: listed.url))))
            .ok.body.json.estimate

        #expect(estimate.url == listed.url)
        #expect(estimate.reference == listed.reference)
        #expect(estimate.datedOn == listed.datedOn)
        #expect(estimate.estimateItems != nil)
    }

    @Test("GET /v2/estimates/:id/pdf returns base64 content")
    func estimatePdf() async throws {
        let listed = try #require(
            try await client.listEstimates(.init()).ok.body.json.estimates.first
        )

        let content = try #require(
            try await client.showEstimateAsPdf(.init(path: .init(id: Self.id(of: listed.url)))).ok.body.json.pdf.content
        )

        #expect(!content.isEmpty)
        #expect(Data(base64Encoded: content, options: .ignoreUnknownCharacters) != nil)
    }

    @Test("An estimate can be itemised, updated, transitioned, duplicated, invoiced and deleted")
    func estimateLifecycle() async throws {
        let contact = try #require(
            try await client.listContacts(.init()).ok.body.json.contacts.first
        )

        let created = try await client.createEstimate(
            .init(body: .json(.init(estimate: .init(
                contact: contact.url,
                datedOn: Self.today,
                estimateType: .quote,
                status: "Draft"
            ))))
        ).created.body.json.estimate

        #expect(created.url.contains("/v2/estimates/"))
        #expect(created.contact == contact.url)
        #expect(created.status == "Draft")
        #expect(created.estimateType == "Quote")
        #expect(created.reference != nil)

        let id = Self.id(of: created.url)

        let item = try await client.createEstimateItem(
            .init(body: .json(.init(
                estimate: id,
                estimateItem: .init(
                    description: "Integration test item",
                    itemType: .hours,
                    price: 95,
                    quantity: 2,
                    salesTaxRate: 20
                )
            )))
        ).created.body.json.estimateItem

        #expect(item.url.contains("/v2/estimate_items/"))
        #expect(item.position == 1)
        #expect(item.price == "95.0")
        #expect(item.salesTaxRate == "20.0")

        let updatedItem = try await client.updateEstimateItem(
            .init(path: .init(id: Self.id(of: item.url)), body: .json(.init(estimateItem: .init(
                description: "Integration test item, revised"
            ))))
        ).ok.body.json.estimateItem

        #expect(updatedItem.description == "Integration test item, revised")

        let comment = try await client.createEstimateItem(
            .init(body: .json(.init(
                estimate: created.url,
                estimateItem: .init(description: "Integration test comment", itemType: .comment, price: 0, quantity: 0)
            )))
        ).created.body.json.estimateItem

        _ = try await client.deleteEstimateItem(.init(path: .init(id: Self.id(of: comment.url)))).ok

        let reference = "IT-\(Int(Date().timeIntervalSince1970))"
        let updated = try await client.updateEstimate(
            .init(path: .init(id: id), body: .json(.init(estimate: .init(reference: reference, notes: "Integration test"))))
        ).ok.body.json.estimate

        #expect(updated.reference == reference)
        #expect(updated.notes == "Integration test")
        #expect(updated.estimateItems?.map(\.url) == [item.url])

        let sent = try await client.markEstimateAsSent(.init(path: .init(id: id))).ok.body.json.estimate
        #expect(sent.status == "Open")

        let approved = try await client.markEstimateAsApproved(.init(path: .init(id: id))).ok.body.json.estimate
        #expect(approved.status == "Approved")

        let rejected = try await client.markEstimateAsRejected(.init(path: .init(id: id))).ok.body.json.estimate
        #expect(rejected.status == "Rejected")

        let draft = try await client.markEstimateAsDraft(.init(path: .init(id: id))).ok.body.json.estimate
        #expect(draft.status == "Draft")

        let duplicate = try await client.duplicateEstimate(.init(path: .init(id: id))).ok.body.json.estimate
        #expect(duplicate.url != created.url)
        #expect(duplicate.status == "Draft")
        #expect(duplicate.estimateItems?.count == 1)

        _ = try await client.deleteEstimate(.init(path: .init(id: Self.id(of: duplicate.url)))).ok

        _ = try await client.markEstimateAsApproved(.init(path: .init(id: id))).ok
        let invoiced = try await client.convertEstimateToInvoice(.init(path: .init(id: id))).ok.body.json.estimate
        #expect(invoiced.status == "Invoiced")

        let invoice = try #require(invoiced.invoice)
        #expect(invoice.contains("/v2/invoices/"))

        let byInvoice = try await client.listEstimates(.init(query: .init(invoice: Self.id(of: invoice)))).ok.body.json
            .estimates
        #expect(byInvoice.map(\.url) == [created.url])

        let byContact = try await client.listEstimates(.init(query: .init(contact: Self.id(of: contact.url)))).ok.body.json
            .estimates
        #expect(byContact.map(\.url).contains(created.url))

        let refused = await #expect(throws: (any Error).self) {
            try await client.deleteEstimate(.init(path: .init(id: id))).ok
        }
        #expect(refused.flatMap(APIError.from)?.status == 409)

        _ = try await client.deleteInvoice(.init(path: .init(id: Self.id(of: invoice)))).ok

        let reopened = try await client.showEstimate(.init(path: .init(id: id))).ok.body.json.estimate
        #expect(reopened.status == "Approved")
        #expect(reopened.invoice == nil)

        _ = try await client.markEstimateAsDraft(.init(path: .init(id: id))).ok
        _ = try await client.deleteEstimate(.init(path: .init(id: id))).ok
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
