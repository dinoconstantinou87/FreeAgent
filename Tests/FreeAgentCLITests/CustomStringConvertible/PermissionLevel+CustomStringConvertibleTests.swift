import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

struct PermissionLevelCustomStringConvertibleTests {
    @Test("names each level as FreeAgent's docs do")
    func namesLevels() {
        #expect(PermissionLevel.allCases.map(\.description) == [
            "No Access",
            "Time",
            "My Money",
            "Contacts & Projects",
            "Invoices, Estimates & Files",
            "Bills",
            "Banking",
            "Tax, Accounting & Users",
            "Full",
        ])
    }
}
