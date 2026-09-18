import Foundation
import HTTPTypes
import Testing

@testable import FreeAgentAPI

struct APIVersionMiddlewareTests {

    // MARK: Internal

    @Test("adds the API version header to request")
    func addsAPIVersionHeader() async throws {
        let header = try #require(HTTPField.Name("X-Api-Version"))
        let middleware = APIVersionMiddleware(version: "2020-01-01")

        let (response, _) = try await middleware.intercept(
            request,
            body: nil,
            baseURL: try #require(URL(string: "https://api.example.com")),
            operationID: "test"
        ) { request, body, _ in
            #expect(request.headerFields[header] == "2020-01-01")
            return (HTTPResponse(status: .ok), body)
        }

        #expect(response.status == .ok)
    }

    @Test("defaults to the version declared by the OpenAPI spec")
    func defaultsToSpecVersion() async throws {
        let header = try #require(HTTPField.Name("X-Api-Version"))
        let middleware = APIVersionMiddleware.apiVersion()

        _ = try await middleware.intercept(
            request,
            body: nil,
            baseURL: try #require(URL(string: "https://api.example.com")),
            operationID: "test"
        ) { request, body, _ in
            #expect(request.headerFields[header] == apiVersion)
            return (HTTPResponse(status: .ok), body)
        }
    }

    // MARK: Private

    private let request = HTTPRequest(method: .get, scheme: "https", authority: "api.example.com", path: "/test")

}
