enum ConfirmationDecision: Equatable, Sendable {
    case proceed
    case prompt
    case refuse

    init(yes: Bool, dryRun: Bool, isInteractive: Bool) {
        self =
            if yes || dryRun {
                .proceed
            } else if isInteractive {
                .prompt
            } else {
                .refuse
            }
    }
}
