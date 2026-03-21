import Foundation
import Mockable

@Mockable
public protocol AuthStorageInterface: Sendable {
    func get() throws -> AuthCredential?
    func set(_ credential: AuthCredential) throws
    func clear() throws
}
