import Foundation
import Noora

// MARK: - DestructiveCommand

protocol DestructiveCommand: MutatingCommand {
    var yes: Bool { get }
    var confirmation: String { get }
}

extension DestructiveCommand {
    func canRun() throws -> Bool {
        let isInteractive = Terminal.isInteractive() && isatty(STDOUT_FILENO) != 0

        return switch ConfirmationDecision(yes: yes, dryRun: dryRun, isInteractive: isInteractive) {
        case .proceed:
            true
        case .refuse:
            throw CommandRefusal.notInteractive
        case .prompt:
            Noora().yesOrNoChoicePrompt(question: TerminalText(stringLiteral: confirmation), defaultAnswer: false)
        }
    }
}
