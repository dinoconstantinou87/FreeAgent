import ArgumentParser
import Testing

@testable import FreeAgentCLI

struct ListLimitTests {

    // MARK: Internal

    @Test("rejects a limit that is not a positive whole number as a usage error", arguments: commands, [
        (flags: ["--limit", "0"], message: "The value '0' is invalid for '--limit <limit>'"),
        (flags: ["--limit=-1"], message: "The value '-1' is invalid for '--limit <limit>'"),
        (flags: ["--limit", "ten"], message: "The value 'ten' is invalid for '--limit <limit>'"),
    ])
    func rejectsInvalidLimit(
        entry: (command: any ParsableCommand.Type, arguments: [String]),
        limit: (flags: [String], message: String)
    ) throws {
        let error = try #require(#expect(throws: (any Error).self) {
            try entry.command.parseAsRoot(entry.arguments + limit.flags)
        })

        #expect(entry.command.exitCode(for: error) == .validationFailure)
        #expect(entry.command.message(for: error) == limit.message)
    }

    @Test("defaults to thirty")
    func defaultsToThirty() throws {
        #expect(try InvoiceListCommand.parse([]).limit.value == 30)
    }

    @Test("accepts a limit above one page")
    func acceptsLargeLimit() throws {
        #expect(try InvoiceListCommand.parse(["--limit", "250"]).limit.value == 250)
    }

    @Test("no longer accepts --page or --per-page on bank transactions", arguments: [
        ["--page", "1"],
        ["--per-page", "50"],
    ])
    func rejectsRemovedPagingFlags(arguments: [String]) {
        #expect(throws: (any Error).self) {
            try BankTransactionListCommand.parse(Self.bankAccount + arguments)
        }
    }

    // MARK: Private

    private static let bankAccount = ["--bank-account", "https://api.sandbox.freeagent.com/v2/bank_accounts/1"]

    private static let commands: [(command: any ParsableCommand.Type, arguments: [String])] = [
        (BankAccountListCommand.self, []),
        (BankTransactionListCommand.self, bankAccount),
        (ContactListCommand.self, []),
        (ExpenseListCommand.self, []),
        (ExplanationListCommand.self, bankAccount),
        (InvoiceListCommand.self, []),
        (InvoiceListRecurringCommand.self, []),
    ]

}
