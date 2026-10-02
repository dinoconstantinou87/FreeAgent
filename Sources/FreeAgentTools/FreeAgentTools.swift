import ArgumentParser

@main
struct FreeAgentTools: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "FreeAgentTools",
        abstract: "Development tools for the FreeAgent OpenAPI spec",
        subcommands: [
            BundleCommand.self,
            ChangedSuitesCommand.self,
        ]
    )
}
