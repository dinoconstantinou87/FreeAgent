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
        let config = try CLIConfig.load()
        let client = AuthClient(config: .init(key: config.clientId, secret: config.clientSecret, environment: environment))
        let services = ServiceGroup(
            configuration: ServiceGroupConfiguration(
                services: [
                    AuthCallbackService(url: config.redirectUri, client: client)
                ],
                gracefulShutdownSignals: [.sigterm],
                logger: Logger(label: "oauth-callback")
            )
        )

        try await withThrowingTaskGroup { group in
            group.addTask {
                try await client.authorize(callbackUrl: config.redirectUri)
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
