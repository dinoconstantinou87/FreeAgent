import ArgumentParser

struct VatReturnCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "vat-return",
        abstract: "Manage VAT returns",
        subcommands: [
            VatReturnListCommand.self,
            VatReturnShowCommand.self,
            VatReturnMarkFiledCommand.self,
            VatReturnMarkUnfiledCommand.self,
            VatReturnMarkPaidCommand.self,
            VatReturnMarkUnpaidCommand.self,
        ]
    )
}
