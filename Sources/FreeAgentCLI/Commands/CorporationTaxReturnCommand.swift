import ArgumentParser

struct CorporationTaxReturnCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "corporation-tax-return",
        abstract: "Manage corporation tax returns",
        subcommands: [
            CorporationTaxReturnListCommand.self,
            CorporationTaxReturnShowCommand.self,
            CorporationTaxReturnMarkFiledCommand.self,
            CorporationTaxReturnMarkUnfiledCommand.self,
            CorporationTaxReturnMarkPaidCommand.self,
            CorporationTaxReturnMarkUnpaidCommand.self,
        ]
    )
}
