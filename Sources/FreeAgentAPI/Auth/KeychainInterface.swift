#if os(macOS)
import Foundation
@preconcurrency import KeychainAccess
import Mockable

// MARK: - KeychainInterface

@Mockable
public protocol KeychainInterface: Sendable {
    func getData(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> Data?
    func set(_ value: Data, key: String, ignoringAttributeSynchronizable: Bool) throws
    func remove(_ key: String, ignoringAttributeSynchronizable: Bool) throws
}

// MARK: - Keychain + @retroactive @unchecked Sendable

// swiftlint:disable:next no_unchecked_sendable
extension Keychain: @retroactive @unchecked Sendable { }

// MARK: - Keychain + KeychainInterface

extension Keychain: KeychainInterface { }
#endif
