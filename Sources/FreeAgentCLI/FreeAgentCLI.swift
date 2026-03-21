import ArgumentParser
import FreeAgentAPI

@main
struct FreeAgentCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "freeagent",
        abstract: "FreeAgent API CLI",
        version: "1.0.0",
        subcommands: [
            SetupCommand.self,
            AuthCommand.self,
            CompanyCommand.self,
            InvoiceCommand.self,
            BillCommand.self,
            ContactCommand.self,
            BankAccountCommand.self,
            BankTransactionCommand.self,
            ExplanationCommand.self,
            CategoryCommand.self,
            ExpenseCommand.self,
        ]
    )
}
