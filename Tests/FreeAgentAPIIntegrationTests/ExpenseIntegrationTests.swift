import Foundation
import Testing

@testable import FreeAgentAPI

@Suite(.enabled(if: IntegrationTest.isModelEnabled("expenses")))
struct ExpenseIntegrationTests {

    // MARK: Lifecycle

    init() throws {
        client = try #require(SandboxClient.makeClient())
    }

    // MARK: Internal

    @Test("GET /v2/expenses returns a typed list")
    func listExpenses() async throws {
        let expenses = try await client.listAllExpenses(.init())
            .ok.body.json.expenses

        #expect(!expenses.isEmpty)

        let expense = try #require(expenses.first)
        #expect(expense.url.contains("/v2/expenses/"))
        #expect(try #require(expense.user).contains("/v2/users/"))
        #expect(try #require(expense.category).contains("/v2/categories/"))
        #expect(expense.grossValue != nil)
        #expect(expense.currency != nil)
        #expect(expense.createdAt != nil)
    }

    @Test("GET /v2/expenses/:id returns a typed expense")
    func showExpense() async throws {
        let listed = try #require(
            try await client.listAllExpenses(.init()).ok.body.json.expenses.first
        )
        let id = String(listed.url.split(separator: "/").last ?? "")

        let expense = try await client.getASingleExpense(.init(path: .init(id: id)))
            .ok.body.json.expense

        #expect(expense.url == listed.url)
        #expect(expense.grossValue == listed.grossValue)
        #expect(expense.datedOn == listed.datedOn)
    }

    @Test("POST /v2/expenses creates an expense and returns it typed")
    func createExpense() async throws {
        let listed = try #require(
            try await client.listAllExpenses(.init()).ok.body.json.expenses.first
        )
        let payload = Components.Schemas.ExpensePayload(
            category: listed.category,
            datedOn: Self.today,
            description: "Integration test expense",
            grossValue: "-12.0",
            user: listed.user
        )

        let expense = try await client.createExpense(.init(body: .json(.init(expense: payload))))
            .created.body.json.expense

        #expect(expense.url.contains("/v2/expenses/"))
        #expect(expense.description == "Integration test expense")
        #expect(expense.grossValue == "-12.0")
        #expect(expense.datedOn == Self.today)
        #expect(expense.createdAt != nil)
    }

    // MARK: Private

    private static var today: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private let client: Client

}
