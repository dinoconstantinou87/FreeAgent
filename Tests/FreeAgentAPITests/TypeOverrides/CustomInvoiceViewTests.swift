import Foundation
import Testing

@testable import FreeAgentAPI

@Suite("CustomInvoiceView")
struct CustomInvoiceViewTests {

    @Test(
        "raw value round-trips for static cases",
        arguments: [
            (CustomInvoiceView.all, "all"),
            (.recentOpenOrOverdue, "recent_open_or_overdue"),
            (.open, "open"),
            (.overdue, "overdue"),
            (.openOrOverdue, "open_or_overdue"),
            (.draft, "draft"),
            (.scheduledToEmail, "scheduled_to_email"),
            (.thankYouEmails, "thank_you_emails"),
            (.reminderEmails, "reminder_emails"),
        ] as [(CustomInvoiceView, String)]
    )
    func rawValueRoundTrips(view: CustomInvoiceView, expected: String) {
        #expect(view.rawValue == expected)
        #expect(CustomInvoiceView(rawValue: expected) == view)
    }

    @Test("lastMonths produces correct raw value")
    func lastMonthsRawValue() {
        #expect(CustomInvoiceView.lastMonths(3).rawValue == "last_3_months")
        #expect(CustomInvoiceView.lastMonths(12).rawValue == "last_12_months")
    }

    @Test("lastMonths parses valid raw values", arguments: [1, 3, 6, 12])
    func lastMonthsParsesValid(months: Int) {
        let view = CustomInvoiceView(rawValue: "last_\(months)_months")
        #expect(view == .lastMonths(months))
    }

    @Test("lastMonths returns nil for zero")
    func lastMonthsRejectsZero() {
        #expect(CustomInvoiceView(rawValue: "last_0_months") == nil)
    }

    @Test("lastMonths returns nil for negative")
    func lastMonthsRejectsNegative() {
        #expect(CustomInvoiceView(rawValue: "last_-1_months") == nil)
    }

    @Test("lastMonths returns nil for non-numeric")
    func lastMonthsRejectsNonNumeric() {
        #expect(CustomInvoiceView(rawValue: "last_abc_months") == nil)
    }

    @Test("init returns nil for unknown raw value")
    func unknownRawValue() {
        #expect(CustomInvoiceView(rawValue: "unknown") == nil)
    }

    @Test("is encodable and decodable", arguments: [
        CustomInvoiceView.all,
        .draft,
        .lastMonths(6),
    ])
    func codable(view: CustomInvoiceView) throws {
        let data = try JSONEncoder().encode(view)
        let decoded = try JSONDecoder().decode(CustomInvoiceView.self, from: data)

        #expect(decoded == view)
    }

    @Test("decoding throws for invalid value")
    func decodingThrowsForInvalid() {
        let data = Data("\"invalid_view\"".utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(CustomInvoiceView.self, from: data)
        }
    }
}
