import ArgumentParser

struct BankTransactionCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "bank-transaction",
        abstract: "Manage bank transactions",
        subcommands: [
            BankTransactionListCommand.self,
            BankTransactionShowCommand.self
        ]
    )
}
