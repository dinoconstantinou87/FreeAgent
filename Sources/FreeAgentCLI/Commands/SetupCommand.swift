import ArgumentParser
import Foundation
import FreeAgentAPI
import Noora

// MARK: - SetupCommand

struct SetupCommand: CredentialCommand {
    static let configuration = CommandConfiguration(
        commandName: "setup",
        abstract: "Set up the FreeAgent CLI"
    )

    func perform() async throws -> URL {
        guard Terminal.canPrompt() else {
            throw SetupCommandError.notInteractive
        }

        let key = Noora().textPrompt(
            title: "FreeAgent app OAuth ID",
            prompt: "What is your FreeAgent app OAuth ID?",
            collapseOnAnswer: true,
            validationRules: [NonEmptyValidationRule(error: "OAuth ID cannot be empty.")]
        )

        let secret = Noora().textPrompt(
            title: "FreeAgent app OAuth secret",
            prompt: "What is your FreeAgent app OAuth secret?",
            collapseOnAnswer: true,
            validationRules: [NonEmptyValidationRule(error: "OAuth secret cannot be empty.")]
        )

        let callbackUrl = Noora().textPrompt(
            title: "FreeAgent app OAuth callbackUrl",
            prompt: "What is your FreeAgent app OAuth redirect URI?",
            collapseOnAnswer: true,
            validationRules: [URLValidationRule(error: "OAuth redirect URI must be a valid URL.")]
        )

        let config = Config(
            auth: .init(
                key: key,
                secret: secret,
                callbackUrl: URL(string: callbackUrl)!
            )
        )

        try config.save()

        return Config.url
    }

    func success(for url: URL) -> String {
        "Saved the OAuth app to \(url.path(percentEncoded: false))"
    }
}

// MARK: - SetupCommandError

enum SetupCommandError: CommandError {
    case notInteractive

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .notInteractive:
            "Setup needs an interactive terminal"
        }
    }

    var exitCode: ExitCode {
        .validationFailure
    }

    var takeaways: [TerminalText] {
        switch self {
        case .notInteractive:
            [
                "Set \(.command("FREEAGENT_AUTH_KEY")), \(.command("FREEAGENT_AUTH_SECRET")) and \(.command("FREEAGENT_AUTH_CALLBACK_URL")) instead"
            ]
        }
    }
}
