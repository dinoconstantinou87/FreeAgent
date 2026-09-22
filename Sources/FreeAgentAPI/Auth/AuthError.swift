import Foundation

public enum AuthError: Error, Equatable {

    case unauthenticated
    case denied(Components.Schemas.OAuthError)
    case declined(error: String, description: String?)
    case unexpected(status: Int?)

    // MARK: Public

    public var message: String? {
        switch self {
        case .unauthenticated, .unexpected:
            nil

        case .denied(let error):
            Self.message(error: error.error, description: error.errorDescription)

        case .declined(let error, let description):
            Self.message(error: error, description: description)
        }
    }

    // MARK: Private

    private static func message(error: String, description: String?) -> String {
        guard let description, !description.isEmpty else {
            return error
        }

        return "\(error): \(description)"
    }

}
