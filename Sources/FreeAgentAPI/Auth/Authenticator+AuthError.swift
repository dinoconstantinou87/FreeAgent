import Foundation
import OAuthenticator

extension Authenticator {
    func login() async throws -> Login {
        do {
            return try await authenticate()
        } catch is AuthenticatorError {
            throw AuthError.unexpected(status: nil)
        }
    }
}
