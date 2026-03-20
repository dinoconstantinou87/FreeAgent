import ArgumentParser

struct CategoryCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "category",
        abstract: "Manage categories",
        subcommands: [
            CategoryListCommand.self
        ]
    )
}
