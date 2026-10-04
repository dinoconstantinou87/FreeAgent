import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("price_list_items")))
struct PriceListItemIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/price_list_items returns a typed, counted list")
    func listPriceListItems() async throws {
        let ok = try await client.listPriceListItems(.init(query: .init(sort: ._hyphen_code))).ok
        let items = try ok.body.json.priceListItems

        #expect(ok.headers.xTotalCount != nil)
        #expect(items.allSatisfy { $0.url.contains("/v2/price_list_items/") })
    }

    @Test("A price list item can be created, updated, listed, shown and deleted")
    func priceListItemLifecycle() async throws {
        let code = "ZZ-INTEGRATION-\(Int(Date().timeIntervalSince1970))"

        let created = try await client.createPriceListItem(
            .init(body: .json(.init(priceListItem: .init(
                code: code,
                description: "Integration test item",
                itemType: .products,
                quantity: 2,
                price: 10.5,
                vatStatus: .standard,
                salesTaxRate: 20,
                secondSalesTaxRate: 5,
                category: "001"
            ))))
        ).created.body.json.priceListItem

        #expect(created.url.contains("/v2/price_list_items/"))
        #expect(created.code == code)
        #expect(created.description == "Integration test item")
        #expect(created.itemType == .products)
        #expect(created.quantity == "2.0")
        #expect(created.price == "10.5")
        #expect(created.vatStatus == .standard)
        #expect(created.salesTaxRate == "20.0")
        #expect(created.secondSalesTaxRate == "5.0")
        #expect(created.category?.hasSuffix("/v2/categories/001") == true)

        let id = Self.id(of: created.url)

        let updated = try await client.updatePriceListItem(
            .init(path: .init(id: id), body: .json(.init(priceListItem: .init(
                code: code + "-UPDATED",
                description: "Integration test item updated",
                itemType: ._hyphen_noUnit,
                quantity: 3,
                price: 12,
                vatStatus: .zero,
                salesTaxRate: 5,
                secondSalesTaxRate: 0,
                category: "041"
            ))))
        ).ok.body.json.priceListItem

        #expect(updated.url == created.url)
        #expect(updated.code == code + "-UPDATED")
        #expect(updated.description == "Integration test item updated")
        #expect(updated.itemType == ._hyphen_noUnit)
        #expect(updated.quantity == "3.0")
        #expect(updated.price == "12.0")
        #expect(updated.vatStatus == .zero)
        #expect(updated.salesTaxRate == "5.0")
        #expect(updated.secondSalesTaxRate == "0.0")
        #expect(updated.category?.hasSuffix("/v2/categories/041") == true)

        _ = try await client.listPriceListItems(.init(query: .init(sort: .code))).ok.body.json.priceListItems

        let shown = try await client.showPriceListItem(.init(path: .init(id: id))).ok.body.json.priceListItem
        #expect(shown.url == created.url)

        _ = try await client.deletePriceListItem(.init(path: .init(id: id))).ok
    }

    // MARK: Private

    private let client: Client

    private static func id(of url: String) -> String {
        String(url.split(separator: "/").last ?? "")
    }

}
