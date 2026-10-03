import FreeAgentAPI
import Testing

@testable import FreeAgentCLI

struct JournalEntryArgumentTests {
    @Test("reads every key into the entry")
    func readsEveryKey() throws {
        let payload = try JournalEntryArgument(
            "category=601,debit-value=-123.45,description=Laptop,user=1,capital-asset-type=2,stock-item=3,stock-altering-quantity=-4,contact=5"
        ).payload

        #expect(payload.category == "601")
        #expect(payload.debitValue == -123.45)
        #expect(payload.description == "Laptop")
        #expect(payload.user == "1")
        #expect(payload.capitalAssetType == "2")
        #expect(payload.stockItem == "3")
        #expect(payload.stockAlteringQuantity == -4)
        #expect(payload.contact == "5")
        #expect(payload.url == nil)
        #expect(payload._destroy == nil)
    }

    @Test("reduces URLs to IDs")
    func reducesURLs() throws {
        let payload = try JournalEntryArgument(
            "category=https://api.freeagent.com/v2/categories/907,user=https://api.freeagent.com/v2/users/32382"
        ).payload

        #expect(payload.category == "907")
        #expect(payload.user == "32382")
    }

    @Test("leaves out keys that are not given")
    func leavesOutMissingKeys() throws {
        let payload = try JournalEntryArgument("category=999").payload

        #expect(payload.category == "999")
        #expect(payload.debitValue == nil)
        #expect(payload.description == nil)
        #expect(payload.user == nil)
    }

    @Test("keeps commas and equals signs inside double quotes")
    func quotedValue() throws {
        let payload = try JournalEntryArgument(#"category=999,description="Rent, March = 2",debit-value=5"#).payload

        #expect(payload.description == "Rent, March = 2")
        #expect(payload.debitValue == 5)
    }

    @Test("ignores spaces around keys")
    func spacedKeys() throws {
        let payload = try JournalEntryArgument("category=999, debit-value=5").payload

        #expect(payload.debitValue == 5)
    }

    @Test(
        "refuses a malformed entry",
        arguments: [
            ("debit-value=5", JournalEntryArgumentError.missingCategory),
            ("category=999,debit=5", .unknownKey("debit")),
            ("category=999,category=280", .repeatedKey(.category)),
            ("category=999,description=", .emptyValue(.description)),
            ("category=999,debit-value=ten", .notANumber(.debitValue, "ten")),
            ("category=999,debit-value=inf", .notANumber(.debitValue, "inf")),
            ("category=999,stock-altering-quantity=1.5", .notANumber(.stockAlteringQuantity, "1.5")),
            ("category=999,5", .missingValue("5")),
            ("category=999,", .missingValue("")),
            (#"category=999,description="Rent"#, .unclosedQuote),
        ]
    )
    func refusesMalformedEntry(argument: String, error: JournalEntryArgumentError) {
        #expect(throws: error) {
            try JournalEntryArgument(argument)
        }
    }

    @Test("names the keys when one is unknown")
    func namesKeys() {
        #expect(
            JournalEntryArgumentError.unknownKey("debit").errorDescription
                == "'debit' is not a key - use category, debit-value, description, user, capital-asset-type, stock-item, stock-altering-quantity, contact"
        )
    }
}
