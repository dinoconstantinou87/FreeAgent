import Testing

@testable import FreeAgentCLI

struct ResourceIDTests {
    @Test("keeps an ID as it is", arguments: ["217677", "2025-04-05"])
    func keepsID(id: String) {
        #expect(ResourceID(id).value == id)
    }

    @Test(
        "reduces a resource URL to its ID",
        arguments: [
            "https://api.freeagent.com/v2/estimates/217677",
            "https://api.sandbox.freeagent.com/v2/estimates/217677",
            "https://api.freeagent.com/v2/estimates/217677/",
        ]
    )
    func reducesURL(url: String) {
        #expect(ResourceID(url).value == "217677")
    }

    @Test("prints as its ID")
    func printsAsID() {
        #expect("\(ResourceID("https://api.freeagent.com/v2/contacts/206540"))" == "206540")
    }
}
