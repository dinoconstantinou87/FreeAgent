import Configuration
import Foundation

// MARK: - CredentialStore

public struct CredentialStore: Sendable {

    // MARK: Public

    public static let defaultDirectory = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".freeagent")

    public static var `default`: CredentialStore {
        #if os(macOS)
        keychain()
        #else
        file()
        #endif
    }

    public static func file(directory: URL = CredentialStore.defaultDirectory) -> CredentialStore {
        CredentialStore(backend: .file(CredentialFile(directory: directory)))
    }

    #if os(macOS)
    public static func keychain(service: String = "freeagent.cli") -> CredentialStore {
        CredentialStore(backend: .keychain(KeychainProvider(service: service)))
    }
    #endif

    public func provider() async -> (any ConfigProvider)? {
        switch backend {
        #if os(macOS)
        case .keychain(let keychain):
            keychain
        #endif
        case .file(let file):
            try? await JSONProvider(filePath: file.path)
        }
    }

    public func write(_ data: Data) throws {
        switch backend {
        #if os(macOS)
        case .keychain(let keychain):
            try keychain.write(data)
        #endif
        case .file(let file):
            try file.write(data)
        }
    }

    public func remove() throws {
        switch backend {
        #if os(macOS)
        case .keychain(let keychain):
            try keychain.remove()
        #endif
        case .file(let file):
            try file.remove()
        }
    }

    // MARK: Private

    private enum Backend: Sendable {
        #if os(macOS)
        case keychain(KeychainProvider)
        #endif
        case file(CredentialFile)
    }

    private let backend: Backend

}
