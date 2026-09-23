import Foundation
import Mockable
import Testing

@testable import FreeAgentAPI

struct FileCredentialStoreTests {

    // MARK: Internal

    @Test("read returns nil when the file has no contents")
    func readReturnsNilWhenMissing() throws {
        given(fileManager).contents(atPath: .value(url.path)).willReturn(nil)

        #expect(try store.read() == nil)
    }

    @Test("read returns the file's contents")
    func readReturnsContents() throws {
        given(fileManager).contents(atPath: .value(url.path)).willReturn(Data("credential".utf8))

        #expect(try store.read() == Data("credential".utf8))
    }

    @Test("write creates the parent directory and writes the data to the file")
    func writeCreatesDirectoryAndWrites() throws {
        given(fileManager).createDirectory(at: .any, withIntermediateDirectories: .any).willReturn()
        given(fileManager).write(.any, to: .any).willReturn()

        try store.write(Data("credential".utf8))

        verify(fileManager)
            .createDirectory(at: .value(url.deletingLastPathComponent()), withIntermediateDirectories: .value(true))
            .called(.once)
        verify(fileManager).write(.value(Data("credential".utf8)), to: .value(url)).called(.once)
    }

    @Test("write does not write when the directory cannot be created")
    func writeStopsWhenDirectoryFails() {
        given(fileManager).createDirectory(at: .any, withIntermediateDirectories: .any)
            .willThrow(CocoaError(.fileWriteNoPermission))

        #expect(throws: CocoaError.self) {
            try store.write(Data("credential".utf8))
        }
        verify(fileManager).write(.any, to: .any).called(.never)
    }

    @Test("remove deletes the file when it exists")
    func removeDeletesFile() throws {
        given(fileManager).fileExists(atPath: .value(url.path)).willReturn(true)
        given(fileManager).removeItem(at: .any).willReturn()

        try store.remove()

        verify(fileManager).removeItem(at: .value(url)).called(.once)
    }

    @Test("remove does nothing when the file is missing")
    func removeSkipsMissingFile() throws {
        given(fileManager).fileExists(atPath: .value(url.path)).willReturn(false)

        try store.remove()

        verify(fileManager).removeItem(at: .any).called(.never)
    }

    // MARK: Private

    private let fileManager = MockFileManagerInterface()
    private let url = URL(fileURLWithPath: "/home/user/.freeagent/credentials.json")

    private var store: FileCredentialStore {
        FileCredentialStore(url: url, fileManager: fileManager)
    }

}
