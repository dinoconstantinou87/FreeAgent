import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing

@testable import FreeAgentAPI

struct DryRunMiddlewareTests {

    // MARK: Internal

    @Test("throws the rendered request instead of sending a write", arguments: [
        HTTPRequest.Method.post,
        .put,
        .patch,
        .delete,
    ])
    func shortCircuitsWrites(method: HTTPRequest.Method) async throws {
        let rendered = await #expect(throws: DryRunRequest.self) {
            try await intercept(request(method)) { _, _, _ in
                Issue.record("next was called")
                return (HTTPResponse(status: .ok), nil)
            }
        }

        #expect(rendered?.method == method.rawValue)
    }

    @Test("passes reads through untouched")
    func passesReadsThrough() async throws {
        let (response, _) = try await intercept(request(.get)) { _, body, _ in
            (HTTPResponse(status: .ok), body)
        }

        #expect(response.status == .ok)
    }

    @Test("composes the absolute URL the transport would request")
    func composesURL() async throws {
        let rendered = await #expect(throws: DryRunRequest.self) {
            try await intercept(request(.post, path: "/v2/invoices?view=open&page=2")) { _, _, _ in
                (HTTPResponse(status: .ok), nil)
            }
        }

        #expect(rendered?.url == URL(string: "https://api.example.com/v2/invoices?view=open&page=2"))
    }

    @Test("redacts the authorization header and keeps the rest")
    func redactsAuthorization() async throws {
        var post = request(.post)
        post.headerFields[.authorization] = "Bearer secret"
        post.headerFields[try #require(HTTPField.Name("X-Api-Version"))] = "2026-09-01"

        let rendered = await #expect(throws: DryRunRequest.self) {
            try await intercept(post) { _, _, _ in
                (HTTPResponse(status: .ok), nil)
            }
        }

        #expect(rendered?.headers["Authorization"] == "[redacted]")
        #expect(rendered?.headers["X-Api-Version"] == "2026-09-01")
    }

    @Test("decodes the JSON body")
    func decodesBody() async throws {
        let rendered = await #expect(throws: DryRunRequest.self) {
            try await intercept(request(.post), body: HTTPBody(#"{"invoice":{"contact":"c"}}"#)) { _, _, _ in
                (HTTPResponse(status: .ok), nil)
            }
        }

        #expect(try rendered?.body == OpenAPIValueContainer(unvalidatedValue: ["invoice": ["contact": "c"]]))
    }

    @Test("represents a missing body as null")
    func representsMissingBodyAsNull() async throws {
        let rendered = await #expect(throws: DryRunRequest.self) {
            try await intercept(request(.delete)) { _, _, _ in
                (HTTPResponse(status: .ok), nil)
            }
        }

        #expect(try #require(rendered?.body).value == nil)
    }

    // MARK: Private

    private func request(_ method: HTTPRequest.Method, path: String = "/test") -> HTTPRequest {
        HTTPRequest(method: method, scheme: "https", authority: "api.example.com", path: path)
    }

    private func intercept(
        _ request: HTTPRequest,
        body: HTTPBody? = nil,
        next: @escaping (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        try await DryRunMiddleware().intercept(
            request,
            body: body,
            baseURL: try #require(URL(string: "https://api.example.com")),
            operationID: "test",
            next: next
        )
    }

}
