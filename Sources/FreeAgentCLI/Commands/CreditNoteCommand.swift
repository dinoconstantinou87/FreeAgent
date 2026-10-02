import ArgumentParser

struct CreditNoteCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "credit-note",
        abstract: "Manage credit notes",
        subcommands: [
            CreditNoteListCommand.self,
            CreditNoteCreateCommand.self,
            CreditNoteShowCommand.self,
            CreditNoteUpdateCommand.self,
            CreditNoteDeleteCommand.self,
            CreditNoteMarkSentCommand.self,
            CreditNoteMarkDraftCommand.self,
            CreditNotePdfCommand.self,
            CreditNoteSendEmailCommand.self,
            CreditNoteCreateItemCommand.self,
            CreditNoteUpdateItemCommand.self,
            CreditNoteDeleteItemCommand.self,
        ]
    )
}
