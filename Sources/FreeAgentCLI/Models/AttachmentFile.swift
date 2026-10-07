import ArgumentParser
import Foundation
import Noora

// MARK: - AttachmentFile

struct AttachmentFile {

    // MARK: Lifecycle

    init(path: String) throws {
        let url = URL(fileURLWithPath: path)
        let ext = url.pathExtension.lowercased()

        guard let contentType = Self.contentTypes[ext] else {
            throw AttachmentFileError.unsupportedFileType(ext)
        }

        do {
            data = try Data(contentsOf: url).base64EncodedString()
        } catch {
            throw AttachmentFileError.unreadable(path: path)
        }

        fileName = url.lastPathComponent
        self.contentType = contentType
    }

    // MARK: Internal

    let data: String
    let fileName: String
    let contentType: String

    // MARK: Private

    private static let contentTypes = [
        "pdf": "application/pdf",
        "png": "image/png",
        "jpg": "image/jpeg",
        "jpeg": "image/jpeg",
        "gif": "image/gif",
    ]

}

// MARK: - AttachmentFileError

enum AttachmentFileError: CommandError {
    case unsupportedFileType(String)
    case unreadable(path: String)

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .unsupportedFileType(let ext):
            "Unsupported attachment type '\(ext)'"
        case .unreadable(let path):
            "Couldn't read \(path)"
        }
    }

    var exitCode: ExitCode {
        .validationFailure
    }

    var takeaways: [TerminalText] {
        switch self {
        case .unsupportedFileType:
            ["Attach a pdf, png, jpg, jpeg or gif file"]
        case .unreadable:
            ["Check the file exists and is readable"]
        }
    }
}
