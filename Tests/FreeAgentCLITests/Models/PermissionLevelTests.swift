import Testing

@testable import FreeAgentCLI

struct PermissionLevelTests {
    @Test("names a known permission level")
    func knownLevel() {
        #expect(PermissionLevel.name(for: 7) == "Tax, Accounting & Users")
    }

    @Test("falls back to the number for an unknown permission level")
    func unknownLevel() {
        #expect(PermissionLevel.name(for: 12) == "12")
    }
}
