import ArgumentParser

@main
struct FreeAgentTools: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "FreeAgentTools",
        abstract: "Development tools for the FreeAgent OpenAPI spec",
        subcommands: [
            BundleCommand.self,
            ChangedSuitesCommand.self,
            CoverageCommand.self,
        ]
    )
}
