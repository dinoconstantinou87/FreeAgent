import ArgumentParser
import FreeAgentAPI
import Foundation
import Noora
import ServiceLifecycle
import Logging

struct LoginCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "login",
        abstract: "Login"
    )
    
    @Option(name: .long)
    var environment: Environment = .production

    mutating func run() async throws {
        let config: CLIConfig
        do {
            config = try CLIConfig.load()
        } catch {
            Noora().error(.alert("No credentials configured"))
            throw ExitCode.failure
        }

        guard let redirectUri = URL(string: config.redirectUri) else {
            Noora().error(.alert("Invalid redirect uri: \(config.redirectUri)"))
            throw ExitCode.failure
        }

        let client = AuthClient(key: config.clientId, secret: config.clientSecret, environment: environment)
        let services = ServiceGroup(
            configuration: ServiceGroupConfiguration(
                services: [
                    AuthCallbackService(url: redirectUri, client: client)
                ],
                gracefulShutdownSignals: [.sigterm],
                logger: Logger(label: "oauth-callback")
            )
        )

        try await withThrowingTaskGroup { group in
            group.addTask {
                try await client.authorize(callbackUrl: redirectUri)
                Noora().success(.alert("Logged in"))
            }

            group.addTask {
                try await services.run()
            }

            try await group.next()
            group.cancelAll()
        }
    }
}
