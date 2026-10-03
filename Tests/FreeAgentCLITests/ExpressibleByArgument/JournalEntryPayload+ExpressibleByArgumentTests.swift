import ArgumentParser
import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

struct JournalEntryPayloadExpressibleByArgumentTests {
    @Test("reads an entry from JSON over several lines")
    func readsJSON() throws {
        let entry = try #require(Components.Schemas.JournalEntryPayload(argument: """
            {
              "category": "907",
              "user": "32382",
              "debit_value": -123.45,
              "description": "Loan, repaid"
            }
            """))

        #expect(entry.category == "907")
        #expect(entry.user == "32382")
        #expect(entry.debitValue == -123.45)
        #expect(entry.description == "Loan, repaid")
    }

    @Test(
        "refuses anything but an entry object",
        arguments: [
            "category=907",
            #"["907"]"#,
            #"{"category": "907", "debit": 10}"#,
            #"{"category": "907", "debit_value": "ten"}"#,
        ]
    )
    func refusesOtherInput(argument: String) {
        #expect(Components.Schemas.JournalEntryPayload(argument: argument) == nil)
    }
}
