import ArgumentParser
import Testing

@testable import FreeAgentCLI

struct DestructiveCommandTests {
    @Test("refuses an unconfirmed destructive command as a usage error")
    func refusesWithoutConfirmation() {
        let error = DestructiveCommandError.confirmationRequired

        #expect(error.exitCode == .validationFailure)
        #expect(error.errorDescription == "Confirmation required when not running interactively")
        #expect(
            error.takeaways.map { $0.plain() } == [
                "Pass '--yes' to confirm",
                "Pass '--dry-run' to preview the request instead",
            ]
        )
    }
}
