import ArgumentParser

struct InvoiceRecurringCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "recurring",
        abstract: "Manage recurring invoices",
        subcommands: [
            InvoiceListRecurringCommand.self,
            InvoiceShowRecurringCommand.self
        ]
    )
}