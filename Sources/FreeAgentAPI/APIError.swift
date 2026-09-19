import Foundation
import OpenAPIRuntime

// MARK: - APIError

public struct APIError: Error, Equatable, Sendable {

    // MARK: Lifecycle

    public init(status: Int, messages: [String] = []) {
        kind = Kind(status: status)
        self.status = status
        self.messages = messages
    }

    public init(kind: Kind, messages: [String] = []) {
        self.kind = kind
        status = nil
        self.messages = messages
    }

    // MARK: Public

    public enum Kind: Equatable, Sendable {
        case unauthenticated
        case forbidden
        case notFound
        case rejected
        case rateLimited
        case serverError
        case unknownOutcome
        case unexpected
    }

    public let kind: Kind
    public let status: Int?
    public let messages: [String]

    public static func from(_ error: any Error) -> APIError? {
        switch error {
        case let error as APIError: error
        case let error as ClientError: from(error.underlyingError)
        default: nil
        }
    }

    // MARK: Internal

    static func messages(from data: Data) -> [String] {
        guard let errors = try? JSONDecoder().decode(Components.Schemas.Errors.self, from: data).errors else {
            return []
        }

        return switch errors {
        case .ErrorObject(let object): [object.error?.message].compactMap(\.self)
        case .ErrorList(let list): list.compactMap(\.message)
        }
    }

}

extension APIError.Kind {
    init(status: Int) {
        self =
            switch status {
            case 401: .unauthenticated
            case 403: .forbidden
            case 404: .notFound
            case 429: .rateLimited
            case 400 ... 499: .rejected
            case 500 ... 599: .serverError
            default: .unexpected
            }
    }
}
