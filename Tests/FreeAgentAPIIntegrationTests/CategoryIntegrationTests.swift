import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("categories")))
struct CategoryIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/categories returns all four typed groups")
    func listCategories() async throws {
        let categories = try await client.listCategories(.init()).ok.body.json

        #expect(!categories.adminExpensesCategories.isEmpty)
        #expect(!categories.costOfSalesCategories.isEmpty)
        #expect(!categories.incomeCategories.isEmpty)
        #expect(!categories.generalCategories.isEmpty)

        let category = try #require(categories.adminExpensesCategories.first)
        #expect(category.url.contains("/v2/categories/"))
        #expect(category.description != nil)
        #expect(category.nominalCode != nil)
        #expect(category.allowableForTax != nil)
    }

    // MARK: Private

    private let client: Client

}
