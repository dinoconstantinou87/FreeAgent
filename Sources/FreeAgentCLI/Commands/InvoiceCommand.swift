import ArgumentParser

struct InvoiceCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "invoice",
        abstract: "Manage invoices",
        subcommands: [
            InvoiceListCommand.self,
            InvoiceCreateCommand.self,
            InvoiceShowCommand.self,
            InvoiceUpdateCommand.self,
            InvoiceDeleteCommand.self,
            InvoiceMarkSentCommand.self,
            InvoiceMarkCancelledCommand.self,
            InvoiceMarkScheduledCommand.self,
            InvoiceMarkDraftCommand.self,
            InvoiceTimelineCommand.self,
            InvoicePdfCommand.self,
            InvoiceSendEmailCommand.self,
            InvoiceCreateItemCommand.self,
            InvoiceRecurringCommand.self
        ]
    )
}
