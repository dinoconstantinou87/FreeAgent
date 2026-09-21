import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

struct InvoiceViewExpressibleByArgumentTests {
    @Test("offers only values it can parse back", arguments: CustomInvoiceView.allValueStrings)
    func offersOnlyParsableValues(value: String) {
        #expect(CustomInvoiceView(rawValue: value) != nil)
    }
}
