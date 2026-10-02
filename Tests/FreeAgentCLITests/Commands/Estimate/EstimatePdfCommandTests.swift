import Testing

@testable import FreeAgentCLI

struct EstimatePdfCommandTests {
    @Test("names the file after the estimate unless told otherwise")
    func namesFileAfterEstimate() throws {
        #expect(try EstimatePdfCommand.parse(["217677"]).path == "estimate-217677.pdf")
        #expect(try EstimatePdfCommand.parse(["217677", "--output", "quote.pdf"]).path == "quote.pdf")
    }
}
