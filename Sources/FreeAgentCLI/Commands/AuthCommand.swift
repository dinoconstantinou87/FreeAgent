import ArgumentParser
import FreeAgentAPI

struct AuthCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "auth",
        abstract: "Authentication",
        subcommands: [
            LoginCommand.self,
            LogoutCommand.self
        ]
    )
}
