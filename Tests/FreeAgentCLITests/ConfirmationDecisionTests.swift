import Testing

@testable import FreeAgentCLI

struct ConfirmationDecisionTests {
    @Test(
        "proceeds on --yes or --dry-run, prompts when interactive, refuses otherwise",
        arguments: [
            (yes: false, dryRun: false, isInteractive: false, expected: ConfirmationDecision.refuse),
            (yes: false, dryRun: false, isInteractive: true, expected: .prompt),
            (yes: false, dryRun: true, isInteractive: false, expected: .proceed),
            (yes: false, dryRun: true, isInteractive: true, expected: .proceed),
            (yes: true, dryRun: false, isInteractive: false, expected: .proceed),
            (yes: true, dryRun: false, isInteractive: true, expected: .proceed),
            (yes: true, dryRun: true, isInteractive: false, expected: .proceed),
            (yes: true, dryRun: true, isInteractive: true, expected: .proceed),
        ]
    )
    func decides(yes: Bool, dryRun: Bool, isInteractive: Bool, expected: ConfirmationDecision) {
        #expect(ConfirmationDecision(yes: yes, dryRun: dryRun, isInteractive: isInteractive) == expected)
    }
}
