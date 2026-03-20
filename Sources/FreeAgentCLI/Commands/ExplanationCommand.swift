import ArgumentParser

struct ExplanationCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "explanation",
        abstract: "Manage bank transaction explanations",
        subcommands: [
            ExplanationListCommand.self,
            ExplanationCreateCommand.self,
            ExplanationShowCommand.self,
            ExplanationDeleteCommand.self
        ]
    )
}
