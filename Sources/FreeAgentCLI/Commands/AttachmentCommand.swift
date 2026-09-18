import ArgumentParser

struct AttachmentCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "attachment",
        abstract: "Manage attachments",
        subcommands: [
            AttachmentShowCommand.self,
            AttachmentDeleteCommand.self,
        ]
    )
}
