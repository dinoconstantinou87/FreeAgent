import ArgumentParser

struct BankAccountCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "bank-account",
        abstract: "Manage bank accounts",
        subcommands: [
            BankAccountListCommand.self,
            BankAccountShowCommand.self
        ]
    )
}
