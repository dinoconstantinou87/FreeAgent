import ArgumentParser

struct BillCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "bill",
        abstract: "Manage bills",
        subcommands: [
            BillListCommand.self,
            BillCreateCommand.self,
            BillShowCommand.self,
            BillUpdateCommand.self,
            BillDeleteCommand.self,
            BillCreateItemCommand.self,
            BillUpdateItemCommand.self,
            BillDeleteItemCommand.self,
        ]
    )
}
