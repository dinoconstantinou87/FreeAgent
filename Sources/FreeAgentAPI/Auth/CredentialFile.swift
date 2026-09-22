import Foundation
import SystemPackage

// MARK: - CredentialFile

struct CredentialFile: Sendable {

    // MARK: Lifecycle

    init(directory: URL) {
        url = directory.appendingPathComponent("credential.json")
    }

    // MARK: Internal

    let url: URL

    var path: FilePath {
        FilePath(url.path)
    }

    func write(_ data: Data) throws {
        let files = FileManager.default
        let directory = url.deletingLastPathComponent()

        if !files.fileExists(atPath: directory.path) {
            try files.createDirectory(
                at: directory,
                withIntermediateDirectories: true,
                attributes: [.posixPermissions: 0o700]
            )
        }

        try remove()

        guard files.createFile(atPath: url.path, contents: data, attributes: [.posixPermissions: 0o600]) else {
            throw CredentialFileError.writeFailed(url.path)
        }
    }

    func remove() throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }

        try FileManager.default.removeItem(at: url)
    }

}

// MARK: - CredentialFileError

enum CredentialFileError: Error, Equatable {
    case writeFailed(String)
}
