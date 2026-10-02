import Foundation

public enum CredentialStoreKind: String, Sendable, CaseIterable {
    #if os(macOS)
    case keychain
    #endif
    case file

    // MARK: Internal

    var store: any CredentialStoreInterface {
        switch self {
        #if os(macOS)
        case .keychain:
            KeychainCredentialStore()
        #endif
        case .file:
            FileCredentialStore()
        }
    }
}
