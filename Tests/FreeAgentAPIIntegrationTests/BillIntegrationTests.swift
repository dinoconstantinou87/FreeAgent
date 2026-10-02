import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.serialized, .enabled(if: IntegrationTest.isModelEnabled("bills")))
struct BillIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/bills returns a typed, counted list")
    func listBills() async throws {
        let ok = try await client.listBills(.init(query: .init(nestedBillItems: true, view: .all, sort: ._hyphen_datedOn))).ok
        let bills = try ok.body.json.bills

        #expect(ok.headers.xTotalCount != nil)
        #expect(bills.allSatisfy { $0.url.contains("/v2/bills/") })
        #expect(bills.allSatisfy { $0.billItems != nil })
    }

    @Test("A bill can be created, itemised, updated, listed and deleted")
    func billLifecycle() async throws {
        let contact = try #require(
            try await client.listContacts(.init()).ok.body.json.contacts.first
        )
        let reference = "IT-BILL-\(Int(Date().timeIntervalSince1970))"

        let created = try await client.createBill(
            .init(body: .json(.init(bill: .init(
                contact: Self.id(of: contact.url),
                reference: reference,
                datedOn: Self.today,
                dueOn: Self.today,
                recurring: .annually
            ))))
        ).created.body.json.bill

        #expect(created.url.contains("/v2/bills/"))
        #expect(created.contact == contact.url)
        #expect(created.recurring == "Annually")

        let id = Self.id(of: created.url)

        let itemised = try await client.updateBill(
            .init(path: .init(id: id), body: .json(.init(bill: .init(billItems: [
                .init(
                    url: "",
                    category: Self.accommodationCategory,
                    description: "Integration test hosting",
                    totalValue: "120.0"
                ),
                .init(
                    url: "",
                    category: Self.accommodationCategory,
                    description: "Integration test domain",
                    totalValue: "12.0",
                    salesTaxRate: "0.0"
                ),
            ]))))
        ).ok.body.json.bill

        let items = try #require(itemised.billItems)
        #expect(items.count == 2)

        let hosting = try #require(items.first)
        #expect(hosting.url.contains("/v2/bill_items/"))

        let domain = try #require(items.last)

        let revised = try await client.updateBill(
            .init(path: .init(id: id), body: .json(.init(bill: .init(billItems: [
                .init(url: Self.id(of: hosting.url), description: "Integration test hosting, revised"),
                .init(url: Self.id(of: domain.url), _destroy: 1),
            ]))))
        ).ok.body.json.bill

        let remaining = try #require(revised.billItems?.first)
        #expect(revised.billItems?.map(\.url) == [hosting.url])
        #expect(remaining.description == "Integration test hosting, revised")

        let updated = try await client.updateBill(
            .init(path: .init(id: id), body: .json(.init(bill: .init(comments: "Integration test"))))
        ).ok.body.json.bill

        #expect(updated.comments == "Integration test")

        _ = try await client.listBills(
            .init(query: .init(
                nestedBillItems: true,
                contact: Self.id(of: contact.url),
                view: .recurring,
                fromDate: Self.today,
                toDate: Self.today
            ))
        ).ok.body.json.bills

        let shown = try await client.showBill(.init(path: .init(id: id))).ok.body.json.bill
        #expect(shown.url == created.url)

        _ = try await client.deleteBill(.init(path: .init(id: id))).ok
    }

    @Test("A paid bill decodes its payment and lock fields")
    func paidBill() async throws {
        let contact = try #require(
            try await client.listContacts(.init()).ok.body.json.contacts.first
        )
        let bankAccount = try #require(
            try await client.listBankAccounts(.init()).ok.body.json.bankAccounts.first
        )

        let bill = try await client.createBill(
            .init(body: .json(.init(bill: .init(
                contact: Self.id(of: contact.url),
                reference: "IT-PAID-\(Int(Date().timeIntervalSince1970))",
                datedOn: Self.today,
                dueOn: Self.today,
                billItems: [
                    .init(category: Self.accommodationCategory, description: "Integration test paid bill", totalValue: "120.0")
                ]
            ))))
        ).created.body.json.bill
        let id = Self.id(of: bill.url)

        let explanation = try await client.createABankTransactionExplanation(
            .init(body: .json(.init(bankTransactionExplanation: .init(
                bankAccount: Self.id(of: bankAccount.url),
                datedOn: Self.today,
                description: "Integration test bill payment",
                grossValue: "-120.0",
                paidBill: id
            ))))
        ).created.body.json.bankTransactionExplanation

        let paid = try await client.showBill(.init(path: .init(id: id))).ok.body.json.bill
        #expect(paid.paidOn != nil)
        #expect(paid.isLocked != nil)
        #expect(paid.lockedAttributes?.isEmpty == false)
        #expect(paid.lockedReason != nil)

        _ = try await client.deleteABankTransactionExplanation(
            .init(path: .init(id: Self.id(of: explanation.url)))
        ).ok
        _ = try await client.deleteBill(.init(path: .init(id: id))).ok
    }

    // MARK: Private

    private static let accommodationCategory = "285"

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
