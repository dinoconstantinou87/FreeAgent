import ArgumentParser

struct ExplanationAttachmentCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "attachment",
        abstract: "Manage attachments on a bank transaction explanation",
        subcommands: [
            ExplanationAttachmentListCommand.self,
            ExplanationAttachmentAddCommand.self,
            ExplanationAttachmentRemoveCommand.self,
        ]
    )
}
