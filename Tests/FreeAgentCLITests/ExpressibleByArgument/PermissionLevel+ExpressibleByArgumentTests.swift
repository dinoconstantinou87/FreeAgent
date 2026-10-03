import ArgumentParser
import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

struct PermissionLevelExpressibleByArgumentTests {
    @Test("takes FreeAgent's integer and names it in help")
    func namesLevelsInHelp() {
        #expect(PermissionLevel(argument: "7") == .taxAccountingAndUsers)
        #expect(PermissionLevel(argument: "9") == nil)
        #expect(PermissionLevel.allValueDescriptions["8"] == "Full")
    }
}
