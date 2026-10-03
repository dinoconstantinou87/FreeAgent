import ArgumentParser
import Testing

@testable import FreeAgentCLI

struct JournalSetCreateCommandTests {
    @Test("needs at least one entry")
    func needsEntry() {
        #expect(throws: (any Error).self) {
            try JournalSetCreateCommand.parse(["--dated-on", "2026-09-30", "--description", "Correction"])
        }
    }

    @Test("takes each entry in order")
    func takesEntries() throws {
        let command = try JournalSetCreateCommand.parse([
            "--dated-on",
            "2026-09-30",
            "--description",
            "Correction",
            "--entry",
            #"{"category": "280", "debit_value": 10}"#,
            "--entry",
            #"{"category": "999", "debit_value": -10}"#,
        ])

        #expect(command.entry.map(\.category) == ["280", "999"])
    }
}
