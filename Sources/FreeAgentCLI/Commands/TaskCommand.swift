import ArgumentParser

struct TaskCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "task",
        abstract: "Manage tasks",
        subcommands: [
            TaskListCommand.self,
            TaskCreateCommand.self,
            TaskShowCommand.self,
            TaskUpdateCommand.self,
            TaskDeleteCommand.self,
        ]
    )
}
