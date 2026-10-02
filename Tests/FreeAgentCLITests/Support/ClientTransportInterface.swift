import Foundation
import HTTPTypes
import Mockable
import OpenAPIRuntime

// MARK: - ClientTransportInterface

@Mockable
protocol ClientTransportInterface: Sendable {
    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?)
}

// MARK: - MockClientTransportInterface + ClientTransport

extension MockClientTransportInterface: ClientTransport { }
