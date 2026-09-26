import Foundation
import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

struct CredentialCommandTests {

    // MARK: Internal

    @Test("names the environment it logged in to")
    func namesLoginEnvironment() throws {
        let command = try LoginCommand.parse(["--environment", "sandbox"])

        #expect(command.success(for: Self.credential(in: .sandbox)) == "Logged in to FreeAgent sandbox")
    }

    @Test("names the environment of the credential it removed")
    func namesLogoutEnvironment() throws {
        let command = try LogoutCommand.parse([])

        #expect(command.success(for: Self.credential(in: .production)) == "Logged out of FreeAgent production")
    }

    @Test("shows where it saved the config")
    func showsConfigPath() throws {
        let command = try SetupCommand.parse([])

        #expect(
            command.success(for: URL(filePath: "/Users/alice/.freeagent/config.json"))
                == "Saved the OAuth app to /Users/alice/.freeagent/config.json"
        )
    }

    // MARK: Private

    private static func credential(in environment: Environment) -> AuthCredential {
        AuthCredential(token: "token", refreshToken: nil, expiresAt: nil, environment: environment)
    }

}
