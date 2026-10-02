import ArgumentParser

struct ContactCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "contact",
        abstract: "Manage contacts",
        subcommands: [
            ContactListCommand.self,
            ContactCreateCommand.self,
            ContactShowCommand.self,
            ContactUpdateCommand.self,
            ContactDeleteCommand.self,
        ]
    )
}
