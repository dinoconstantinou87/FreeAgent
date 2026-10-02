import ArgumentParser
import Foundation
import FreeAgentAPI

struct LoginCommand: CredentialCommand {
    static let configuration = CommandConfiguration(
        commandName: "login",
        abstract: "Login"
    )

    @Option(name: .long)
    var environment = Environment.production

    func perform() async throws -> AuthCredential {
        let reader = try await Config.reader(environment: environment).scoped(to: "auth")
        let config = try AuthConfig(config: reader)
        let client = try AuthClient(
            config: config,
            storage: AuthStorage(config: reader),
            userAuthenticator: LoopbackUserAuthenticator(callbackUrl: config.callbackUrl).userAuthenticator
        )

        return try await client.authorize()
    }

    func success(for credential: AuthCredential) -> String {
        "Logged in to FreeAgent \(credential.environment.rawValue)"
    }
}
