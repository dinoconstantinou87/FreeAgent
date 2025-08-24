import Foundation
import Security

public struct OAuthTokenStorage: Sendable {
    private let service = "com.freeagent.cli"
    private let account = "oauth_token"
    
    public init() {}
    
    public func save(_ token: OAuthToken) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(token)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unableToStore(status)
        }
    }
    
    public func load() throws -> OAuthToken? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return nil
            }
            throw KeychainError.unableToLoad(status)
        }
        
        guard let data = dataTypeRef as? Data else {
            throw KeychainError.unexpectedData
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(OAuthToken.self, from: data)
    }
    
    public func clear() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unableToDelete(status)
        }
    }
    
    public func hasValidToken() throws -> Bool {
        guard let token = try load() else {
            return false
        }
        return !token.isExpired
    }
}

public enum KeychainError: LocalizedError {
    case unableToStore(OSStatus)
    case unableToLoad(OSStatus)
    case unableToDelete(OSStatus)
    case unexpectedData
    
    public var errorDescription: String? {
        switch self {
        case .unableToStore(let status):
            return "Unable to store token in keychain: \(status)"
        case .unableToLoad(let status):
            return "Unable to load token from keychain: \(status)"
        case .unableToDelete(let status):
            return "Unable to delete token from keychain: \(status)"
        case .unexpectedData:
            return "Unexpected data format in keychain"
        }
    }
}