import ArgumentParser

struct EstimateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "estimate",
        abstract: "Manage estimates",
        subcommands: [
            EstimateListCommand.self,
            EstimateCreateCommand.self,
            EstimateShowCommand.self,
            EstimateUpdateCommand.self,
            EstimateDeleteCommand.self,
            EstimateDuplicateCommand.self,
            EstimateMarkSentCommand.self,
            EstimateMarkApprovedCommand.self,
            EstimateMarkRejectedCommand.self,
            EstimateMarkDraftCommand.self,
            EstimateConvertToInvoiceCommand.self,
            EstimatePdfCommand.self,
            EstimateSendEmailCommand.self,
            EstimateCreateItemCommand.self,
            EstimateUpdateItemCommand.self,
            EstimateDeleteItemCommand.self,
        ]
    )
}
