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

    @Test("shows the saved config relative to the home directory")
    func abbreviatesConfigPath() throws {
        let command = try SetupCommand.parse([])

        #expect(command.success(for: Config.url) == "Saved the OAuth app to ~/.freeagent/config.json")
    }

    @Test("shows a config outside the home directory in full")
    func keepsPathOutsideHome() throws {
        let command = try SetupCommand.parse([])

        #expect(
            command.success(for: URL(filePath: "/etc/freeagent/config.json"))
                == "Saved the OAuth app to /etc/freeagent/config.json"
        )
    }

    // MARK: Private

    private static func credential(in environment: Environment) -> AuthCredential {
        AuthCredential(token: "token", refreshToken: nil, expiresAt: nil, environment: environment)
    }

}
