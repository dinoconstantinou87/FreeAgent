import Foundation

public struct FileCredentialStore: CredentialStoreInterface {

    // MARK: Lifecycle

    public init(
        url: URL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".freeagent")
            .appendingPathComponent("credentials.json")
    ) {
        self.url = url
    }

    // MARK: Public

    public func read() throws -> Data? {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }

        return try Data(contentsOf: url)
    }

    public func write(_ data: Data) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)
    }

    public func remove() throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }

        try FileManager.default.removeItem(at: url)
    }

    // MARK: Private

    private let url: URL

}
