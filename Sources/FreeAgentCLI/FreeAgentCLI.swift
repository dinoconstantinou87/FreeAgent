import ArgumentParser
import FreeAgentAPI

@main
struct FreeAgentCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "freeagent",
        abstract: "FreeAgent API CLI",
        version: version,
        subcommands: [
            SetupCommand.self,
            CompletionCommand.self,
            AuthCommand.self,
            CompanyCommand.self,
            InvoiceCommand.self,
            EstimateCommand.self,
            CreditNoteCommand.self,
            ProjectCommand.self,
            TaskCommand.self,
            UserCommand.self,
            TimeslipCommand.self,
            BillCommand.self,
            ContactCommand.self,
            BankAccountCommand.self,
            BankTransactionCommand.self,
            ExplanationCommand.self,
            CategoryCommand.self,
            JournalSetCommand.self,
            PriceListItemCommand.self,
            ExpenseCommand.self,
            AttachmentCommand.self,
            VatReturnCommand.self,
            CorporationTaxReturnCommand.self,
            SelfAssessmentReturnCommand.self,
        ]
    )
}
