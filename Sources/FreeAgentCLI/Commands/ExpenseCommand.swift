import ArgumentParser

struct ExpenseCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "expense",
        abstract: "Manage expenses",
        subcommands: [
            ExpenseListCommand.self,
            ExpenseCreateCommand.self,
            ExpenseShowCommand.self
        ]
    )
}
