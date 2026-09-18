import Foundation

// MARK: - AttachmentFile

struct AttachmentFile {

    // MARK: Lifecycle

    init(path: String) throws {
        let url = URL(fileURLWithPath: path)

        guard let contentType = Self.contentTypes[url.pathExtension.lowercased()] else {
            throw AttachmentFileError.unsupportedFileType(url.pathExtension)
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

enum AttachmentFileError: Error, CustomStringConvertible {
    case unsupportedFileType(String)

    var description: String {
        switch self {
        case .unsupportedFileType(let ext):
            "Unsupported attachment type '\(ext)'. Supported types: pdf, png, jpg, jpeg, gif"
        }
    }
}
