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

        data = try Data(contentsOf: url).base64EncodedString()
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

    var errorDescription: String? {
        switch self {
        case .unsupportedFileType(let ext):
            "Unsupported attachment type '\(ext)'"
        }
    }

    var exitCode: ExitCode {
        .validationFailure
    }

    var takeaways: [TerminalText] {
        switch self {
        case .unsupportedFileType:
            ["Attach a pdf, png, jpg, jpeg or gif file"]
        }
    }
}
