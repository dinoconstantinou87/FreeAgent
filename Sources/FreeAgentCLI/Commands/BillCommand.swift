import ArgumentParser

struct BillCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "bill",
        abstract: "Manage bills",
        subcommands: [
            BillCreateCommand.self
        ]
    )
}
