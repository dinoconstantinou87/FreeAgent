import ArgumentParser

struct ProjectCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "project",
        abstract: "Manage projects",
        subcommands: [
            ProjectListCommand.self,
            ProjectCreateCommand.self,
            ProjectShowCommand.self,
            ProjectUpdateCommand.self,
            ProjectDeleteCommand.self,
        ]
    )
}
