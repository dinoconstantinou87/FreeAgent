import ArgumentParser
import Foundation
import FreeAgentAPI

struct CategoryListCommand: ShowCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List categories"
    )

    static let title = "Categories"

    static let sections = [FieldSection<Components.Schemas.CategoryListResponse>]()

    static let tables = [
        FieldTable<Components.Schemas.CategoryListResponse>("Admin Expenses", items: { $0.adminExpensesCategories }) {
            spendingColumns
        },
        FieldTable("Cost Of Sales", items: { $0.costOfSalesCategories }) {
            spendingColumns
        },
        FieldTable("Income", items: { $0.incomeCategories }) {
            nameColumns
            Field("Sales Tax") { .text($0.autoSalesTaxRate) }
        },
        FieldTable("General", items: { $0.generalCategories }) {
            nameColumns
            Field("Tax Reporting") { .text($0.taxReportingName) }
        },
    ]

    @FieldBuilder<Components.Schemas.Category>
    static var nameColumns: [Field<Components.Schemas.Category>] {
        Field("ID") { .id(url: $0.url) }
        Field("Description") { .text($0.description) }
    }

    @FieldBuilder<Components.Schemas.Category>
    static var spendingColumns: [Field<Components.Schemas.Category>] {
        nameColumns
        Field("Sales Tax") { .text($0.autoSalesTaxRate) }
        Field("Allowable") { .flag($0.allowableForTax) }
        Field("Tax Reporting") { .text($0.taxReportingName) }
    }

    @Flag(name: .long, help: "Output JSON")
    var json = false

    func fetch(client: Client) async throws -> Components.Schemas.CategoryListResponse {
        try await client.listCategories(.init()).ok.body.json
    }

    func record(
        in response: Components.Schemas.CategoryListResponse
    ) -> Components.Schemas.CategoryListResponse {
        response
    }
}
