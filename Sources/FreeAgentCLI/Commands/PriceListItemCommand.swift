import ArgumentParser

struct PriceListItemCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "price-list-item",
        abstract: "Manage price list items",
        subcommands: [
            PriceListItemListCommand.self,
            PriceListItemCreateCommand.self,
            PriceListItemShowCommand.self,
            PriceListItemUpdateCommand.self,
            PriceListItemDeleteCommand.self,
        ]
    )
}
