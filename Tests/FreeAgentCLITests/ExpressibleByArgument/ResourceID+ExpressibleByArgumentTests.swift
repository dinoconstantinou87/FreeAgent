import Testing

@testable import FreeAgentCLI

struct ResourceIDExpressibleByArgumentTests {
    @Test("parses an ID or a URL from the command line")
    func parsesIDOrURL() throws {
        #expect(try EstimateShowCommand.parse(["217677"]).id.value == "217677")
        #expect(try EstimateShowCommand.parse(["https://api.freeagent.com/v2/estimates/217677"]).id.value == "217677")
    }

    @Test("rejects an empty value")
    func rejectsEmpty() {
        #expect(ResourceID(argument: "") == nil)
    }
}
