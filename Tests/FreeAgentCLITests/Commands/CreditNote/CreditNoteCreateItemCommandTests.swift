import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

struct CreditNoteCreateItemCommandTests {
    @Test("names the new item by the last item FreeAgent returns")
    func namesLastItem() throws {
        let command = try CreditNoteCreateItemCommand.parse(["779164", "--description", "Refund"])

        let message = command.success(for: .init(creditNote: .init(
            url: "https://api.freeagent.com/v2/credit_notes/779164",
            creditNoteItems: [
                .init(url: "https://api.freeagent.com/v2/invoice_items/1"),
                .init(url: "https://api.freeagent.com/v2/invoice_items/2"),
            ]
        )))

        #expect(message == "Created item https://api.freeagent.com/v2/invoice_items/2 on credit note 779164")
    }

    @Test("names only the credit note when FreeAgent returns no items")
    func namesCreditNoteWithoutItems() throws {
        let command = try CreditNoteCreateItemCommand.parse(["779164", "--description", "Refund"])

        let message = command.success(for: .init(creditNote: .init(url: "https://api.freeagent.com/v2/credit_notes/779164")))

        #expect(message == "Created item on credit note 779164")
    }
}
