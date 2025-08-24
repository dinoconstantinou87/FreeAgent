import ArgumentParser
import FreeAgentAPI

struct AuthCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "auth",
        abstract: "Manage FreeAgent API authentication",
        subcommands: [
            LoginCommand.self,
            StatusCommand.self,
            LogoutCommand.self
        ]
    )
}