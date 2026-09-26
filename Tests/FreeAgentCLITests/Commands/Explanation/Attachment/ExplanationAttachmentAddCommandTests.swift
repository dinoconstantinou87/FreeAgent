import ArgumentParser
import Testing

@testable import FreeAgentCLI

struct ExplanationAttachmentAddCommandTests {
    @Test("rejects an unsupported attachment type as a usage error")
    func rejectsUnsupportedType() {
        let error = ExplanationAttachmentAddCommandError.unsupportedFileType("txt")

        #expect(error.exitCode == .validationFailure)
        #expect(error.errorDescription == "Unsupported attachment type 'txt'")
        #expect(error.takeaways.map { $0.plain() } == ["Attach a pdf, png, jpg, jpeg or gif file"])
    }
}
