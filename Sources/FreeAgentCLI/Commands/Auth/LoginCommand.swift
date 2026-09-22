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
        let config = try await Config.load()
        let client = AuthClient(
            config: .init(config.auth, environment: environment),
            userAuthenticator: LoopbackUserAuthenticator(callbackUrl: config.auth.callbackUrl).userAuthenticator
        )

        try await client.authorize()

        Noora().success(.alert("Logged in"))
    }
}
