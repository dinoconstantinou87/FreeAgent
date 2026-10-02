import ArgumentParser
import Testing

@testable import FreeAgentCLI

struct InvoiceCreateCommandTests {

    // MARK: Internal

    @Test("refuses --include-timeslips without --project, since FreeAgent would bill nothing")
    func includeTimeslipsNeedsProject() {
        #expect(throws: (any Error).self) {
            try InvoiceCreateCommand.parse(arguments + ["--include-timeslips", "billed_grouped_by_timeslip"])
        }
    }

    @Test("accepts --include-timeslips with --project")
    func includeTimeslipsWithProject() throws {
        let command = try InvoiceCreateCommand.parse(
            arguments + ["--project", "44160", "--include-timeslips", "billed_grouped_by_timeslip"]
        )

        #expect(command.project?.value == "44160")
        #expect(command.includeTimeslips == .billedGroupedByTimeslip)
    }

    @Test("refuses --include-expenses without --project, since FreeAgent would bill nothing")
    func includeExpensesNeedsProject() {
        #expect(throws: (any Error).self) {
            try InvoiceCreateCommand.parse(arguments + ["--include-expenses", "billed_grouped_by_expense"])
        }
    }

    @Test("accepts --include-expenses with --project")
    func includeExpensesWithProject() throws {
        let command = try InvoiceCreateCommand.parse(
            arguments + ["--project", "44170", "--include-expenses", "billed_grouped_by_expense"]
        )

        #expect(command.project?.value == "44170")
        #expect(command.includeExpenses == .billedGroupedByExpense)
    }

    // MARK: Private

    private let arguments = ["--contact", "206516", "--dated-on", "2026-10-02", "--payment-terms-in-days", "30"]
}
