import Foundation
import Mockable

@Mockable
public protocol CredentialStoreInterface: Sendable {
    func read() throws -> Data?
    func write(_ data: Data) throws
    func remove() throws
}
