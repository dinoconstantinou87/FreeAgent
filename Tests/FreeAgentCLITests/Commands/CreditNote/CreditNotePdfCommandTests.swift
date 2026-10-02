import Testing

@testable import FreeAgentCLI

struct CreditNotePdfCommandTests {
    @Test("names the file after the credit note unless told otherwise")
    func namesFileAfterCreditNote() throws {
        #expect(try CreditNotePdfCommand.parse(["779164"]).path == "credit-note-779164.pdf")
        #expect(try CreditNotePdfCommand.parse(["779164", "--output", "refund.pdf"]).path == "refund.pdf")
    }
}
