import Foundation
import Testing

@testable import FreeAgentCLI

struct ListCellTests {

    // MARK: Internal

    @Test("shows the last path component of a resource URL as its ID")
    func formatsID() {
        #expect(format(.id(url: "https://api.freeagent.com/v2/invoices/773656")) == "773656")
    }

    @Test(
        "shows a hyphen for any missing value",
        arguments: [ListCell.text(nil), .date(nil), .status(nil), .currency(nil, code: "GBP")]
    )
    func formatsMissingValue(cell: ListCell) {
        #expect(format(cell) == "-")
    }

    @Test("shows text, dates and statuses as FreeAgent sends them")
    func formatsText() {
        #expect(format(.text("INV-001")) == "INV-001")
        #expect(format(.date("2026-09-20")) == "2026-09-20")
        #expect(format(.status("Overdue")) == "Overdue")
    }

    @Test(
        "formats an amount in its currency",
        arguments: [
            ("228.0", "GBP", "£228.00"),
            ("-45.99", "GBP", "-£45.99"),
            ("5018.37", "GBP", "£5,018.37"),
            ("120.5", "EUR", "€120.50"),
        ]
    )
    func formatsCurrency(amount: String, code: String, expected: String) {
        #expect(format(.currency(amount, code: code)) == expected)
    }

    @Test("formats an amount without a currency to two decimal places")
    func formatsAmountWithoutCurrency() {
        #expect(format(.currency("-840.0", code: nil)) == "-840.00")
        #expect(format(.currency("2500", code: nil)) == "2,500.00")
    }

    @Test("shows an amount it cannot parse as FreeAgent sent it")
    func keepsUnparsableAmount() {
        #expect(format(.currency("n/a", code: "GBP")) == "n/a")
    }

    // MARK: Private

    private func format(_ cell: ListCell) -> String {
        cell.formatted(locale: Locale(identifier: "en_GB"))
    }
}
