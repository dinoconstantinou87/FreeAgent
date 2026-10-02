import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

struct ViewFilterExpressibleByArgumentTests {
    @Test("offers every named view")
    func offersNamedViews() {
        #expect(CreditNoteViewFilter.allValueStrings == Components.Schemas.CreditNoteViewName.allCases.map(\.rawValue))
    }

    @Test("parses last_N_months from the command line")
    func parsesLastMonths() {
        #expect(CreditNoteViewFilter(argument: "last_3_months") == .lastMonths(3))
    }
}
