import ArgumentParser
import Testing

@testable import FreeAgentCLI

struct ExpenseRecurringOptionsTests {
    @Test("refuses --recurring-end-date without --recurring, since FreeAgent ignores it")
    func endDateNeedsRecurring() {
        #expect(throws: (any Error).self) {
            try ExpenseRecurringOptions.parse(["--recurring-end-date", "2027-03-15"])
        }
    }

    @Test("accepts --recurring-end-date with --recurring")
    func endDateWithRecurring() throws {
        let options = try ExpenseRecurringOptions.parse(["--recurring", "Monthly", "--recurring-end-date", "2027-03-15"])

        #expect(options.recurring == .monthly)
        #expect(options.recurringEndDate == "2027-03-15")
    }

    @Test("refuses --recurring-end-date without --recurring on expense update")
    func updateEndDateNeedsRecurring() {
        #expect(throws: (any Error).self) {
            try ExpenseUpdateCommand.parse(["577139", "--recurring-end-date", "2027-03-15"])
        }
    }
}
