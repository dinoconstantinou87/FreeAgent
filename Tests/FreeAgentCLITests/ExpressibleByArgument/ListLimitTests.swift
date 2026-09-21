import Testing

@testable import FreeAgentCLI

struct ListLimitTests {
    @Test("parses a positive whole number", arguments: [("1", 1), ("30", 30), ("250", 250)])
    func parsesArgument(argument: String, value: Int) {
        #expect(ListLimit(argument: argument)?.value == value)
    }

    @Test("defaults to thirty")
    func defaultsToThirty() {
        #expect(ListLimit.default.value == 30)
    }

    @Test("describes itself by its value")
    func describesValue() {
        #expect(ListLimit.default.description == "30")
    }
}
