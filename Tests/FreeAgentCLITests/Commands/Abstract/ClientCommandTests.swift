import ArgumentParser
import Testing

@testable import FreeAgentCLI

struct ClientCommandTests {
    @Test("reports a command that was declined as a plain failure")
    func reportsDeclinedCommand() {
        let error = ClientCommandError.cancelled

        #expect(error.exitCode == .failure)
        #expect(error.errorDescription == "Cancelled, nothing was changed")
    }
}
