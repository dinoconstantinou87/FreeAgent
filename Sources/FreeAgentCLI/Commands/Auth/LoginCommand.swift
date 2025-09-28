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
        let config = try await Config.load()
        let client = AuthClient(config: .init(key: config.auth.key, secret: config.auth.secret, environment: environment))
        let services = ServiceGroup(
            configuration: ServiceGroupConfiguration(
                services: [
                    AuthCallbackService(url: config.auth.callbackUrl, client: client)
                ],
                gracefulShutdownSignals: [.sigterm],
                logger: Logger(label: "oauth-callback")
            )
        )

        try await withThrowingTaskGroup { group in
            group.addTask {
                try await client.authorize(callbackUrl: config.auth.callbackUrl)
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
