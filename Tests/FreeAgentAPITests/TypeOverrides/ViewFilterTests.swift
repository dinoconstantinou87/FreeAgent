import Foundation
import Testing

@testable import FreeAgentAPI

struct ViewFilterTests {

    @Test("raw value round-trips for every named invoice view", arguments: Components.Schemas.InvoiceViewName.allCases)
    func invoiceNamesRoundTrip(name: Components.Schemas.InvoiceViewName) {
        #expect(InvoiceViewFilter.named(name).rawValue == name.rawValue)
        #expect(InvoiceViewFilter(rawValue: name.rawValue) == .named(name))
    }

    @Test("raw value round-trips for every named credit note view", arguments: Components.Schemas.CreditNoteViewName.allCases)
    func creditNoteNamesRoundTrip(name: Components.Schemas.CreditNoteViewName) {
        #expect(CreditNoteViewFilter.named(name).rawValue == name.rawValue)
        #expect(CreditNoteViewFilter(rawValue: name.rawValue) == .named(name))
    }

    @Test("keeps each resource's named views to itself")
    func namesAreScoped() {
        #expect(CreditNoteViewFilter(rawValue: "refunded") == .named(.refunded))
        #expect(InvoiceViewFilter(rawValue: "refunded") == nil)
    }

    @Test("lastMonths produces correct raw value")
    func lastMonthsRawValue() {
        #expect(InvoiceViewFilter.lastMonths(3).rawValue == "last_3_months")
        #expect(CreditNoteViewFilter.lastMonths(12).rawValue == "last_12_months")
    }

    @Test("lastMonths parses valid raw values", arguments: [1, 3, 6, 12])
    func lastMonthsParsesValid(months: Int) {
        #expect(InvoiceViewFilter(rawValue: "last_\(months)_months") == .lastMonths(months))
        #expect(CreditNoteViewFilter(rawValue: "last_\(months)_months") == .lastMonths(months))
    }

    @Test("lastMonths returns nil for zero")
    func lastMonthsRejectsZero() {
        #expect(InvoiceViewFilter(rawValue: "last_0_months") == nil)
    }

    @Test("lastMonths returns nil for negative")
    func lastMonthsRejectsNegative() {
        #expect(InvoiceViewFilter(rawValue: "last_-1_months") == nil)
    }

    @Test("lastMonths returns nil for non-numeric")
    func lastMonthsRejectsNonNumeric() {
        #expect(InvoiceViewFilter(rawValue: "last_abc_months") == nil)
    }

    @Test("init returns nil for unknown raw value")
    func unknownRawValue() {
        #expect(InvoiceViewFilter(rawValue: "unknown") == nil)
    }

    @Test("is encodable and decodable", arguments: [
        InvoiceViewFilter.named(.all),
        .named(.draft),
        .lastMonths(6),
    ])
    func codable(view: InvoiceViewFilter) throws {
        let data = try JSONEncoder().encode(view)
        let decoded = try JSONDecoder().decode(InvoiceViewFilter.self, from: data)

        #expect(decoded == view)
    }

    @Test("decoding throws for invalid value")
    func decodingThrowsForInvalid() {
        let data = Data("\"invalid_view\"".utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(InvoiceViewFilter.self, from: data)
        }
    }
}
