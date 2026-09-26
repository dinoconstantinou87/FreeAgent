import ArgumentParser
import Foundation
import Testing

@testable import FreeAgentCLI

struct InvoicePdfCommandTests {

    // MARK: Internal

    @Test("names the file after the invoice unless told otherwise")
    func namesFileAfterInvoice() throws {
        #expect(try InvoicePdfCommand.parse(["1234"]).path == "invoice-1234.pdf")
        #expect(try InvoicePdfCommand.parse(["1234", "--output", "008.pdf"]).path == "008.pdf")
    }

    @Test("saves without asking when nothing is at the path")
    func savesToNewFile() throws {
        let command = try InvoicePdfCommand.parse(["1234", "--output", Self.missingPath()])

        #expect(try command.canRun())
    }

    @Test("overwrites an existing file when given --clobber")
    func overwritesWithClobber() throws {
        let path = try Self.existingPath()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let command = try InvoicePdfCommand.parse(["1234", "--output", path, "--clobber"])

        #expect(try command.canRun())
    }

    @Test("ignores an existing file when printing JSON")
    func ignoresFileForJSON() throws {
        let path = try Self.existingPath()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let command = try InvoicePdfCommand.parse(["1234", "--output", path, "--json"])

        #expect(try command.canRun())
    }

    @Test("refuses to overwrite an existing file as a usage error")
    func refusesToOverwrite() {
        let error = InvoicePdfCommandError.fileExists(path: "invoice-1234.pdf")

        #expect(error.exitCode == .validationFailure)
        #expect(error.errorDescription == "invoice-1234.pdf already exists")
        #expect(
            error.takeaways.map { $0.plain() } == [
                "Pass '--clobber' to overwrite it",
                "Pass '--output' to save somewhere else",
            ]
        )
    }

    // MARK: Private

    private static func missingPath() -> String {
        FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).pdf").path
    }

    private static func existingPath() throws -> String {
        let path = missingPath()
        try Data("%PDF".utf8).write(to: URL(fileURLWithPath: path))
        return path
    }

}
