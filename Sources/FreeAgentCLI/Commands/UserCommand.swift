import ArgumentParser

struct UserCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "user",
        abstract: "Manage users",
        subcommands: [
            UserListCommand.self,
            UserCreateCommand.self,
            UserShowCommand.self,
            UserUpdateCommand.self,
            UserDeleteCommand.self,
        ]
    )
}
