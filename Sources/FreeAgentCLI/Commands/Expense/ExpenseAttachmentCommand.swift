import ArgumentParser

struct ExpenseAttachmentCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "attachment",
        abstract: "Manage the attachment on an expense",
        subcommands: [
            ExpenseAttachmentAddCommand.self,
            ExpenseAttachmentRemoveCommand.self,
        ]
    )
}
