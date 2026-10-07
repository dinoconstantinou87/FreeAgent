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

    @Test("GET /v2/expenses returns a typed, counted list")
    func listExpenses() async throws {
        let ok = try await client.listAllExpenses(.init(query: .init(view: .recent, sort: ._hyphen_datedOn))).ok
        let expenses = try ok.body.json.expenses

        #expect(ok.headers.xTotalCount != nil)
        #expect(!expenses.isEmpty)
        #expect(expenses.allSatisfy { $0.url.contains("/v2/expenses/") })
        #expect(expenses.allSatisfy { $0.user?.contains("/v2/users/") == true })
        #expect(expenses.allSatisfy { $0.category?.contains("/v2/categories/") == true })
    }

    @Test("An expense can be created, updated, listed, shown and deleted")
    func expenseLifecycle() async throws {
        let user = try await client.showCurrentUser(.init()).ok.body.json.user

        let created = try await client.createExpense(
            .init(body: .json(.init(expense: .init(
                user: Self.id(of: user.url),
                category: "285",
                datedOn: Self.today,
                description: "ZZ Integration Test Expense",
                grossValue: "-60.0",
                salesTaxRate: "20.0",
                receiptReference: "REC-1",
                recurring: .monthly,
                recurringEndDate: Self.date(monthsFromNow: 6)
            ))))
        ).created.body.json.expense

        #expect(created.url.contains("/v2/expenses/"))
        #expect(created.user == user.url)
        #expect(try #require(created.category).hasSuffix("/v2/categories/285"))
        #expect(created.datedOn == Self.today)
        #expect(created.description == "ZZ Integration Test Expense")
        #expect(created.grossValue == "-60.0")
        #expect(created.salesTaxRate == "20.0")
        #expect(created.receiptReference == "REC-1")
        #expect(created.recurring == "Monthly")
        #expect(created.recurringEndDate == Self.date(monthsFromNow: 6))
        #expect(created.nextRecursOn != nil)

        let id = Self.id(of: created.url)

        let updated = try await client.updateExpense(
            .init(path: .init(id: id), body: .json(.init(expense: .init(
                description: "ZZ Integration Test Expense Updated",
                manualSalesTaxAmount: "1.5",
                recurring: .quarterly,
                recurringEndDate: Self.date(monthsFromNow: 9)
            ))))
        ).ok.body.json.expense

        #expect(updated.url == created.url)
        #expect(updated.description == "ZZ Integration Test Expense Updated")
        #expect(updated.manualSalesTaxAmount == "1.5")
        #expect(updated.recurring == "Quarterly")
        #expect(updated.recurringEndDate == Self.date(monthsFromNow: 9))

        _ = try await client.listAllExpenses(
            .init(query: .init(
                view: .recurring,
                fromDate: Self.today,
                toDate: Self.today,
                updatedSince: created.createdAt?.addingTimeInterval(-1).ISO8601Format(),
                user: Self.id(of: user.url)
            ))
        ).ok.body.json.expenses

        let shown = try await client.getASingleExpense(.init(path: .init(id: id))).ok.body.json.expense
        #expect(shown.url == created.url)

        _ = try await client.deleteExpense(.init(path: .init(id: id))).ok
    }

    @Test("A mileage claim decodes its mileage fields")
    func mileageClaim() async throws {
        let user = try await client.showCurrentUser(.init()).ok.body.json.user

        let created = try await client.createExpense(
            .init(body: .json(.init(expense: .init(
                user: Self.id(of: user.url),
                category: "249",
                datedOn: Self.today,
                description: "ZZ Integration Test Mileage",
                mileage: "42",
                vehicleType: .car,
                engineType: .diesel,
                engineSize: "1601-2000cc",
                haveVatReceipt: true
            ))))
        ).created.body.json.expense

        #expect(created.mileage == "42.0")
        #expect(created.vehicleType == "Car")
        #expect(created.engineType == "Diesel")
        #expect(created.engineSize == "1601-2000cc")
        #expect(created.haveVatReceipt == true)
        #expect(created.engineTypeIndex != nil)
        #expect(created.engineSizeIndex != nil)
        #expect(created.reclaimMileage != nil)
        #expect(created.initialRateMileage != nil)
        #expect(created.reclaimMileageRate != nil)
        #expect(created.rebillMileageRate != nil)

        let id = Self.id(of: created.url)

        let updated = try await client.updateExpense(
            .init(path: .init(id: id), body: .json(.init(expense: .init(
                mileage: "50",
                vehicleType: .motorcycle,
                haveVatReceipt: false
            ))))
        ).ok.body.json.expense

        #expect(updated.mileage == "50.0")
        #expect(updated.vehicleType == "Motorcycle")
        #expect(updated.haveVatReceipt == false)

        _ = try await client.deleteExpense(.init(path: .init(id: id))).ok
    }

    @Test("An expense attachment is sent on create, removed with _destroy and added on update")
    func attachment() async throws {
        let user = try await client.showCurrentUser(.init()).ok.body.json.user

        let created = try await client.createExpense(
            .init(body: .json(.init(expense: .init(
                user: Self.id(of: user.url),
                category: "285",
                datedOn: Self.today,
                description: "ZZ Integration Test Attachment",
                grossValue: "-12.0",
                attachment: .init(
                    data: Self.onePixelPNG,
                    fileName: "receipt.png",
                    contentType: .imagePng,
                    description: "Integration test receipt"
                )
            ))))
        ).created.body.json.expense

        let attached = try #require(created.attachment)
        #expect(attached.url.contains("/v2/attachments/"))
        #expect(attached.fileName == "receipt.png")
        #expect(attached.contentType == "image/png")
        #expect(attached.description == "Integration test receipt")

        let id = Self.id(of: created.url)

        let removed = try await client.updateExpense(
            .init(path: .init(id: id), body: .json(.init(expense: .init(attachment: .init(_destroy: 1)))))
        ).ok.body.json.expense

        #expect(removed.attachment == nil)

        let added = try await client.updateExpense(
            .init(path: .init(id: id), body: .json(.init(expense: .init(attachment: .init(
                data: Self.onePixelPNG,
                fileName: "replacement.png",
                contentType: "image/png"
            )))))
        ).ok.body.json.expense

        #expect(added.attachment?.fileName == "replacement.png")

        _ = try await client.deleteExpense(.init(path: .init(id: id))).ok
    }

    @Test("GET /v2/expenses/mileage_settings returns typed engine options and rates")
    func mileageSettings() async throws {
        let settings = try await client.showMileageSettings(.init()).ok.body.json.mileageSettings

        #expect(!settings.engineTypeAndSizeOptions.isEmpty)
        #expect(settings.engineTypeAndSizeOptions.allSatisfy { !$0.value.additionalProperties.isEmpty })
        #expect(!settings.mileageRates.isEmpty)
        #expect(settings.mileageRates.allSatisfy { $0.value.basicRateLimit != nil })
    }

    @Test("An expense rebilled through invoice create decodes its lock fields")
    func rebilledExpense() async throws {
        let project = try #require(
            try await client.listProjects(.init()).ok.body.json.projects
                .last { !($0.name?.hasPrefix("ZZ Integration Test") ?? false) }
        )
        let contact = try #require(project.contact)
        let user = try await client.showCurrentUser(.init()).ok.body.json.user

        let expense = try await client.createExpense(
            .init(body: .json(.init(expense: .init(
                user: Self.id(of: user.url),
                category: "285",
                datedOn: Self.today,
                description: "ZZ Integration Test Rebill",
                grossValue: "-30.0",
                project: Self.id(of: project.url),
                rebillType: .markup,
                rebillFactor: "0.1"
            ))))
        ).created.body.json.expense
        let id = Self.id(of: expense.url)

        #expect(expense.project == project.url)
        #expect(expense.projectName != nil)
        #expect(expense.contactName != nil)
        #expect(expense.rebillType == "markup")
        #expect(expense.rebillFactor == "0.1")
        #expect(expense.rebillToProject == project.url)

        _ = try await client.listAllExpenses(.init(query: .init(project: Self.id(of: project.url)))).ok.body.json.expenses

        let invoice = try await client.createInvoice(
            .init(body: .json(.init(invoice: .init(
                contact: Self.id(of: contact),
                project: Self.id(of: project.url),
                includeExpenses: .billedGroupedByExpense,
                datedOn: Self.today,
                paymentTermsInDays: 30
            ))))
        ).created.body.json.invoice

        let rebilled = try await client.getASingleExpense(.init(path: .init(id: id))).ok.body.json.expense
        #expect(rebilled.rebilledOnInvoice == invoice.url)
        #expect(rebilled.rebilledOnInvoiceItem != nil)
        #expect(rebilled.lockedAttributes?.isEmpty == false)
        #expect(rebilled.lockedReason != nil)

        _ = try await client.deleteInvoice(.init(path: .init(id: Self.id(of: invoice.url)))).ok
        _ = try await client.deleteExpense(.init(path: .init(id: id))).ok
    }

    // MARK: Private

    private static let onePixelPNG =
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="

    private static var today: String {
        date(monthsFromNow: 0)
    }

    private let client: Client

    private static func date(monthsFromNow months: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = Calendar(identifier: .gregorian).date(byAdding: .month, value: months, to: Date()) ?? Date()
        return formatter.string(from: date)
    }

    private static func id(of url: String) -> String {
        String(url.split(separator: "/").last ?? "")
    }

}
