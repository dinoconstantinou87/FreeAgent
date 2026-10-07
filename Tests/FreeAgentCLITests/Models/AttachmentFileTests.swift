import ArgumentParser
import Foundation
import Testing

@testable import FreeAgentCLI

struct AttachmentFileTests {

    // MARK: Internal

    @Test(
        "takes the content type from the extension, ignoring case",
        arguments: [
            ("pdf", "application/pdf"),
            ("png", "image/png"),
            ("jpg", "image/jpeg"),
            ("JPEG", "image/jpeg"),
            ("gif", "image/gif"),
        ]
    )
    func contentType(ext: String, contentType: String) throws {
        let path = try Self.file(ext: ext, contents: "receipt")

        let attachment = try AttachmentFile(path: path)

        #expect(attachment.contentType == contentType)
        #expect(attachment.fileName == URL(fileURLWithPath: path).lastPathComponent)
        #expect(attachment.data == Data("receipt".utf8).base64EncodedString())
    }

    @Test("rejects an unsupported attachment type as a usage error")
    func rejectsUnsupportedType() throws {
        let path = try Self.file(ext: "txt", contents: "receipt")

        let error = #expect(throws: AttachmentFileError.self) {
            try AttachmentFile(path: path)
        }

        #expect(error?.exitCode == .validationFailure)
        #expect(error?.errorDescription == "Unsupported attachment type 'txt'")
        #expect(error?.takeaways.map { $0.plain() } == ["Attach a pdf, png, jpg, jpeg or gif file"])
    }

    @Test("reports a file it can't read as a usage error, naming the path")
    func rejectsUnreadableFile() {
        let path = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).pdf").path

        let error = #expect(throws: AttachmentFileError.self) {
            try AttachmentFile(path: path)
        }

        #expect(error?.exitCode == .validationFailure)
        #expect(error?.errorDescription == "Couldn't read \(path)")
        #expect(error?.takeaways.map { $0.plain() } == ["Check the file exists and is readable"])
    }

    // MARK: Private

    private static func file(ext: String, contents: String) throws -> String {
        let path = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).\(ext)").path
        try Data(contents.utf8).write(to: URL(fileURLWithPath: path))
        return path
    }

}
