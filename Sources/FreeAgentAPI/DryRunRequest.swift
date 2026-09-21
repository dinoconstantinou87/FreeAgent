import Foundation
import HTTPTypes
import OpenAPIRuntime

public struct DryRunRequest: Error, Codable, Equatable, Sendable {

    // MARK: Lifecycle

    init(_ request: HTTPRequest, body: HTTPBody?, baseURL: URL) async throws {
        method = request.method.rawValue
        url = try Self.url(of: request, baseURL: baseURL)
        headers = Self.headers(of: request)
        self.body = try await Self.body(of: body)
    }

    // MARK: Public

    public let method: String
    public let url: URL
    public let headers: [String: String]
    public let body: OpenAPIValueContainer

    public static func from(_ error: any Error) -> DryRunRequest? {
        switch error {
        case let error as DryRunRequest: error
        case let error as ClientError: from(error.underlyingError)
        default: nil
        }
    }

    // MARK: Private

    private static let redacted = "[redacted]"

    private static func url(of request: HTTPRequest, baseURL: URL) throws -> URL {
        guard
            var components = URLComponents(string: baseURL.absoluteString),
            let path = URLComponents(string: request.path ?? "")
        else {
            throw URLError(.badURL)
        }

        components.percentEncodedPath += path.percentEncodedPath
        components.percentEncodedQuery = path.percentEncodedQuery

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        return url
    }

    private static func headers(of request: HTTPRequest) -> [String: String] {
        var headers = [String: String]()

        for field in request.headerFields {
            let name = field.name.rawName
            headers[name] = headers[name].map { "\($0), \(field.value)" } ?? field.value
        }

        if headers[HTTPField.Name.authorization.rawName] != nil {
            headers[HTTPField.Name.authorization.rawName] = redacted
        }

        return headers
    }

    private static func body(of body: HTTPBody?) async throws -> OpenAPIValueContainer {
        guard let body else { return nil }

        let data = try await Data(collecting: body, upTo: .max)
        return try JSONDecoder().decode(OpenAPIValueContainer.self, from: data)
    }
}
