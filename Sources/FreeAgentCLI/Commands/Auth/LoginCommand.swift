import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora

struct LoginCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "login",
        abstract: "Login"
    )

    @Option(name: .long)
    var environment = Environment.production

    mutating func run() async throws {
        let config = try await AuthConfig(config: Config.reader(environment: environment).scoped(to: "auth"))
        let client = AuthClient(
            config: config,
            userAuthenticator: LoopbackUserAuthenticator(callbackUrl: config.callbackUrl).userAuthenticator
        )

        try await client.authorize()

        Noora().success(.alert("Logged in"))
    }
}
