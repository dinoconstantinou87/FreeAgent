import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("bills")))
struct BillIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("POST /v2/bills creates a bill and returns it typed")
    func createBill() async throws {
        let contact = try #require(
            try await client.listContacts(.init()).ok.body.json.contacts.first
        )
        let item = Components.Schemas.BillItemPayload(
            category: Self.adminExpensesCategoryURL,
            description: "Integration test bill item",
            totalValue: "120.0"
        )
        let payload = Components.Schemas.BillCreatePayload(
            contact: contact.url,
            reference: "INTEGRATION-\(Int(Date().timeIntervalSince1970))",
            datedOn: Self.today,
            dueOn: Self.today,
            billItems: [item]
        )

        let bill = try await client.createBill(.init(body: .json(.init(bill: payload))))
            .created.body.json.bill

        #expect(bill.url.contains("/v2/bills/"))
        #expect(bill.contact == contact.url)
        #expect(bill.totalValue == "120.0")
        #expect(bill.status != nil)
        #expect(bill.isLocked != nil)
        #expect(bill.createdAt != nil)
    }

    // MARK: Private

    private static let adminExpensesCategoryURL =
        "https://api.sandbox.freeagent.com/v2/categories/285"

    private static var today: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private let client: Client

}
