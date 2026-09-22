import Foundation
import SystemPackage

// MARK: - CredentialFile

public struct CredentialFile: Sendable {

    // MARK: Lifecycle

    public init(directory: URL = CredentialFile.defaultDirectory) {
        url = directory.appendingPathComponent("credential.json")
    }

    // MARK: Public

    public static let defaultDirectory = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".freeagent")

    public let url: URL

    public var path: FilePath {
        FilePath(url.path)
    }

    public func write(_ data: Data) throws {
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

    public func remove() throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }

        try FileManager.default.removeItem(at: url)
    }

}

// MARK: - CredentialFileError

public enum CredentialFileError: Error, Equatable {
    case writeFailed(String)
}
