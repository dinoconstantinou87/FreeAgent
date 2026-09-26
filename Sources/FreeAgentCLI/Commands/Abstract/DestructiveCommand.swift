import ArgumentParser
import Noora

// MARK: - DestructiveCommand

protocol DestructiveCommand: MutatingCommand {
    var yes: Bool { get }
    var confirmation: String { get }
}

extension DestructiveCommand {
    func canRun() throws -> Bool {
        switch ConfirmationDecision(yes: yes, dryRun: dryRun, isInteractive: Terminal.canPrompt()) {
        case .proceed:
            true
        case .refuse:
            throw DestructiveCommandError.confirmationRequired
        case .prompt:
            Noora().yesOrNoChoicePrompt(question: TerminalText(stringLiteral: confirmation), defaultAnswer: false)
        }
    }
}

// MARK: - DestructiveCommandError

enum DestructiveCommandError: CommandError {
    case confirmationRequired

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .confirmationRequired:
            "Confirmation required when not running interactively"
        }
    }

    var exitCode: ExitCode {
        .validationFailure
    }

    var takeaways: [TerminalText] {
        switch self {
        case .confirmationRequired:
            [
                "Pass \(.command("--yes")) to confirm",
                "Pass \(.command("--dry-run")) to preview the request instead",
            ]
        }
    }
}
