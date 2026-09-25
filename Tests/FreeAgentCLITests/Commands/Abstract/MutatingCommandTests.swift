import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

struct MutatingCommandTests {
    @Test("names a created record by its URL")
    func namesCreatedRecord() throws {
        let command = try InvoiceCreateCommand.parse([
            "--contact",
            "1",
            "--dated-on",
            "2026-09-25",
            "--payment-terms-in-days",
            "30",
        ])

        let message = command.success(for: .init(invoice: .init(url: "https://api.freeagent.com/v2/invoices/1234")))

        #expect(message == "Created invoice https://api.freeagent.com/v2/invoices/1234")
    }

    @Test("names a created item by its URL and its invoice by the ID given")
    func namesCreatedItem() throws {
        let command = try InvoiceCreateItemCommand.parse(["1234", "--description", "Consulting"])

        let message = command.success(
            for: .init(invoiceItem: .init(url: "https://api.freeagent.com/v2/invoice_items/5678"))
        )

        #expect(message == "Created item https://api.freeagent.com/v2/invoice_items/5678 on invoice 1234")
    }

    @Test("names a changed record by the ID given")
    func namesChangedRecord() throws {
        let command = try InvoiceMarkSentCommand.parse(["1234"])

        let message = command.success(for: .init(invoice: .init(url: "https://api.freeagent.com/v2/invoices/1234")))

        #expect(message == "Marked invoice 1234 as sent")
    }

    @Test(
        "counts attachments only when there is more than one",
        arguments: [
            (files: ["a.pdf"], expected: "Added the attachment to explanation 55"),
            (files: ["a.pdf", "b.png"], expected: "Added 2 attachments to explanation 55"),
        ]
    )
    func countsAddedAttachments(files: [String], expected: String) throws {
        let command = try ExplanationAttachmentAddCommand.parse(["55"] + files.flatMap { ["--file", $0] })

        #expect(command.success(for: .init(attachments: [])) == expected)
    }

    @Test(
        "counts removed attachments only when there is more than one",
        arguments: [
            (count: 1, expected: "Removed the attachment from explanation 55"),
            (count: 2, expected: "Removed 2 attachments from explanation 55"),
        ]
    )
    func countsRemovedAttachments(count: Int, expected: String) throws {
        let urls = (1...count).flatMap { ["--attachment", "https://api.freeagent.com/v2/attachments/\($0)"] }
        let command = try ExplanationAttachmentRemoveCommand.parse(["55"] + urls)

        #expect(command.success(for: .init(attachments: [])) == expected)
    }

    @Test("confirms a request with no response body from the arguments alone")
    func confirmsEmptyResponse() throws {
        #expect(try InvoiceDeleteCommand.parse(["1234"]).success(for: EmptyResponse()) == "Deleted invoice 1234")
        #expect(
            try InvoiceSendEmailCommand.parse(["1234", "--to", "alice@example.com"]).success(for: EmptyResponse())
                == "Sent invoice 1234 to alice@example.com"
        )
    }

    @Test("offers --json only when FreeAgent sends a response body")
    func offersJSONWithBody() throws {
        #expect(try InvoiceMarkSentCommand.parse(["1234", "--json"]).json)
        #expect(try !InvoiceDeleteCommand.parse(["1234"]).json)
        #expect(throws: (any Error).self) { try InvoiceDeleteCommand.parse(["1234", "--json"]) }
        #expect(throws: (any Error).self) {
            try InvoiceSendEmailCommand.parse(["1234", "--to", "alice@example.com", "--json"])
        }
    }
}
