import Foundation
import Mockable

@Mockable
public protocol KeychainInterface: Sendable {
    func getData(_ key: String) throws -> Data?
    func set(_ value: Data, key: String) throws
    func remove(_ key: String) throws
}
