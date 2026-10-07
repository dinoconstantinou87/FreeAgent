import ArgumentParser
import Testing

@testable import FreeAgentCLI

struct ExpenseAttachmentOptionsTests {
    @Test("refuses --attachment-description without --attachment")
    func descriptionNeedsAttachment() {
        #expect(throws: (any Error).self) {
            try ExpenseAttachmentOptions.parse(["--attachment-description", "Hotel receipt"])
        }
    }

    @Test("accepts --attachment-description with --attachment")
    func descriptionWithAttachment() throws {
        let options = try ExpenseAttachmentOptions.parse([
            "--attachment",
            "receipt.pdf",
            "--attachment-description",
            "Hotel receipt",
        ])

        #expect(options.path == "receipt.pdf")
        #expect(options.description == "Hotel receipt")
    }

    @Test("refuses --attachment with --remove-attachment on expense update")
    func updateAttachmentAndRemove() {
        #expect(throws: (any Error).self) {
            try ExpenseUpdateCommand.parse(["577139", "--attachment", "receipt.pdf", "--remove-attachment"])
        }
    }

    @Test("accepts --remove-attachment alone on expense update")
    func updateRemove() throws {
        let command = try ExpenseUpdateCommand.parse(["577139", "--remove-attachment"])

        #expect(command.removeAttachment)
    }
}
