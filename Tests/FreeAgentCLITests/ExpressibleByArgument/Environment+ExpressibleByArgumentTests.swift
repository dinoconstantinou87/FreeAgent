import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

struct EnvironmentExpressibleByArgumentTests {
    @Test("offers every environment as a completion value")
    func offersEveryEnvironment() {
        #expect(Environment.allValueStrings == ["production", "sandbox"])
    }
}
