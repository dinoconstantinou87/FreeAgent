import ArgumentParser
import Testing

@testable import FreeAgentCLI

struct SetupCommandTests {
    @Test("refuses to run without a terminal as a usage error")
    func refusesWithoutTerminal() {
        let error = SetupCommandError.notInteractive

        #expect(error.exitCode == .validationFailure)
        #expect(error.errorDescription == "Setup needs an interactive terminal")
        #expect(
            error.takeaways.map { $0.plain() } == [
                "Set 'FREEAGENT_AUTH_KEY', 'FREEAGENT_AUTH_SECRET' and 'FREEAGENT_AUTH_CALLBACK_URL' instead"
            ]
        )
    }
}
