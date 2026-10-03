import ArgumentParser

struct JournalSetCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "journal-set",
        abstract: "Manage journal sets",
        subcommands: [
            JournalSetListCommand.self,
            JournalSetCreateCommand.self,
            JournalSetShowCommand.self,
            JournalSetUpdateCommand.self,
            JournalSetDeleteCommand.self,
            JournalSetOpeningBalancesCommand.self,
        ]
    )
}
