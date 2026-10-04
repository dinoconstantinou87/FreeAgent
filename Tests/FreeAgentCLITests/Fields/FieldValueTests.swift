import Foundation
import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

struct FieldValueTests {

    // MARK: Internal

    @Test("shows the last path component of a resource URL as its ID")
    func formatsID() {
        #expect(format(.id(url: "https://api.freeagent.com/v2/invoices/773656")) == "773656")
    }

    @Test(
        "has no text for a missing value",
        arguments: [
            FieldValue.id(url: nil),
            .text(nil),
            .date(nil),
            .timestamp(nil),
            .currency(nil, code: "GBP"),
            .percent(nil),
            .hours(nil),
            .number(nil),
            .bytes(nil),
            .flag(nil),
            .status(nil),
        ]
    )
    func formatsMissingValue(value: FieldValue) {
        #expect(format(value) == nil)
    }

    @Test("treats an empty string as missing", arguments: [FieldValue.text(""), .date(""), .status(""), .id(url: "")])
    func formatsEmptyValue(value: FieldValue) {
        #expect(format(value) == nil)
    }

    @Test("shows text, dates and statuses as FreeAgent sends them")
    func formatsText() {
        #expect(format(.text("INV-001")) == "INV-001")
        #expect(format(.date("2026-09-20")) == "2026-09-20")
        #expect(format(.status("Overdue")) == "Overdue")
    }

    @Test("shows an enum as the value FreeAgent sends")
    func formatsEnum() {
        #expect(format(.text(Components.Schemas.PriceListItemType._hyphen_noUnit)) == "-no unit-")
        #expect(format(.status(Components.Schemas.TaskStatus.completed)) == "Completed")
        #expect(format(.text(Components.Schemas.VatStatus?.none)) == nil)
    }

    @Test("shows a described value by its description")
    func formatsDescribed() {
        #expect(format(.text(PermissionLevel.full)) == PermissionLevel.full.description)
    }

    @Test("formats an amount in its currency enum")
    func formatsCurrencyEnum() {
        #expect(format(.currency("120.5", code: Components.Schemas.Currency.eur)) == "€120.50")
        #expect(format(.currency("-840.0", code: Components.Schemas.Currency?.none)) == "-840.00")
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

    @Test("formats a rate as a percentage", arguments: [("20.0", "20%"), ("12.5", "12.5%"), ("0.0", "0%")])
    func formatsPercent(rate: String, expected: String) {
        #expect(format(.percent(rate)) == expected)
    }

    @Test("shows a rate it cannot parse as FreeAgent sent it")
    func keepsUnparsablePercent() {
        #expect(format(.percent("n/a")) == "n/a")
    }

    @Test(
        "formats hours as hours and minutes",
        arguments: [("0.0", "0:00"), ("2.5", "2:30"), ("1.01666667", "1:01"), ("0.03333333", "0:02"), ("12.0", "12:00")]
    )
    func formatsHours(hours: String, expected: String) {
        #expect(format(.hours(hours)) == expected)
    }

    @Test("shows hours it cannot parse as FreeAgent sent them")
    func keepsUnparsableHours() {
        #expect(format(.hours("n/a")) == "n/a")
    }

    @Test("formats a timestamp as a short date and time in the time zone")
    func formatsTimestamp() {
        #expect(format(.timestamp(Date(timeIntervalSince1970: 1_756_212_159))) == "26 Aug 2025 at 12:42")
    }

    @Test("groups the digits of a number")
    func formatsNumber() {
        #expect(format(.number(12345)) == "12,345")
    }

    @Test("formats a file size", arguments: [(135_228, "135 kB"), (2_500_000, "2.5 MB")])
    func formatsBytes(bytes: Int, expected: String) {
        #expect(format(.bytes(bytes)) == expected)
    }

    @Test("shows a flag as yes or no")
    func formatsFlag() {
        #expect(format(.flag(true)) == "Yes")
        #expect(format(.flag(false)) == "No")
    }

    // MARK: Private

    private func format(_ value: FieldValue) -> String? {
        value.formatted(locale: Locale(identifier: "en_GB"), timeZone: TimeZone(identifier: "UTC")!)
    }
}
