import Foundation

public struct FileCredentialStore: CredentialStoreInterface {

    // MARK: Lifecycle

    public init(
        url: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".freeagent")
            .appendingPathComponent("credentials.json"),
        fileManager: any FileManagerInterface = FileManager.default
    ) {
        self.url = url
        self.fileManager = fileManager
    }

    // MARK: Public

    public func read() throws -> Data? {
        fileManager.contents(atPath: url.path)
    }

    public func write(_ data: Data) throws {
        try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try fileManager.write(data, to: url)
    }

    public func remove() throws {
        guard fileManager.fileExists(atPath: url.path) else {
            return
        }

        try fileManager.removeItem(at: url)
    }

    // MARK: Private

    private let url: URL
    private let fileManager: any FileManagerInterface

}
