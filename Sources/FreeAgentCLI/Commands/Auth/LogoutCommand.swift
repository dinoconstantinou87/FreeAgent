import ArgumentParser
import Foundation
import FreeAgentAPI

struct LogoutCommand: CredentialCommand {
    static let configuration = CommandConfiguration(
        commandName: "logout",
        abstract: "Logout"
    )

    func perform() async throws -> AuthCredential {
        let storage = AuthStorage()

        guard let credential = try storage.get() else {
            throw AuthError.unauthenticated
        }

        try storage.clear()
        return credential
    }

    func success(for credential: AuthCredential) -> String {
        "Logged out of FreeAgent \(credential.environment.rawValue)"
    }
}
