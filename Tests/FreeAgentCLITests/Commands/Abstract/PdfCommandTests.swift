import ArgumentParser
import Testing

@testable import FreeAgentCLI

struct PdfCommandTests {
    @Test("refuses to overwrite an existing file as a usage error")
    func refusesToOverwrite() {
        let error = PdfCommandError.fileExists(path: "invoice-1234.pdf")

        #expect(error.exitCode == .validationFailure)
        #expect(error.errorDescription == "invoice-1234.pdf already exists")
        #expect(
            error.takeaways.map { $0.plain() } == [
                "Pass '--clobber' to overwrite it",
                "Pass '--output' to save somewhere else",
            ]
        )
    }
}
