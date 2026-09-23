import Foundation
import Testing

@testable import FreeAgentAPI

// MARK: - FileCredentialStoreTests

final class FileCredentialStoreTests {

    // MARK: Lifecycle

    deinit {
        try? FileManager.default.removeItem(at: directory)
    }

    // MARK: Internal

    @Test("read returns nil when the file is missing")
    func readReturnsNilWhenMissing() throws {
        #expect(try store.read() == nil)
    }

    @Test("read returns what write stored")
    func readReturnsWrittenData() throws {
        try store.write(Data("credential".utf8))

        #expect(try store.read() == Data("credential".utf8))
    }

    @Test("write creates the missing parent directory")
    func writeCreatesDirectory() throws {
        #expect(!FileManager.default.fileExists(atPath: directory.path))

        try store.write(Data("credential".utf8))

        #expect(FileManager.default.fileExists(atPath: url.path))
    }

    @Test("write replaces the previous contents")
    func writeReplacesContents() throws {
        try store.write(Data("first".utf8))
        try store.write(Data("second".utf8))

        #expect(try store.read() == Data("second".utf8))
    }

    @Test("remove deletes the file")
    func removeDeletesFile() throws {
        try store.write(Data("credential".utf8))

        try store.remove()

        #expect(!FileManager.default.fileExists(atPath: url.path))
        #expect(try store.read() == nil)
    }

    @Test("remove succeeds when the file is missing")
    func removeSucceedsWhenMissing() throws {
        try store.remove()

        #expect(try store.read() == nil)
    }

    // MARK: Private

    private let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("FileCredentialStoreTests-\(UUID().uuidString)")

    private var url: URL {
        directory.appendingPathComponent("credentials.json")
    }

    private var store: FileCredentialStore {
        FileCredentialStore(url: url)
    }

}
