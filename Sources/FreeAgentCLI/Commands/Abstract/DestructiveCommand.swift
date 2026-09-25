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
            throw CommandRefusal.notInteractive
        case .prompt:
            Noora().yesOrNoChoicePrompt(question: TerminalText(stringLiteral: confirmation), defaultAnswer: false)
        }
    }
}
