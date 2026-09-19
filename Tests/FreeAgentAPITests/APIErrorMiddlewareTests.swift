import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing

@testable import FreeAgentAPI

struct APIErrorMiddlewareTests {

    // MARK: Internal

    @Test("passes successful responses through untouched")
    func passesSuccessThrough() async throws {
        let (response, _) = try await intercept(request(.get)) { _, body, _ in
            (HTTPResponse(status: .ok), body)
        }

        #expect(response.status == .ok)
    }

    @Test("passes redirects through untouched")
    func passesRedirectsThrough() async throws {
        let (response, _) = try await intercept(request(.get)) { _, body, _ in
            (HTTPResponse(status: .found), body)
        }

        #expect(response.status == .found)
    }

    @Test("throws a typed error carrying the status and the message from the body")
    func throwsTypedErrorForFailureStatus() async throws {
        let error = await #expect(throws: APIError.self) {
            try await intercept(request(.get)) { _, _, _ in
                (
                    HTTPResponse(status: .init(code: 404)),
                    HTTPBody(#"{"errors":{"error":{"message":"Resource not found"}}}"#)
                )
            }
        }

        #expect(error?.kind == .notFound)
        #expect(error?.status == 404)
        #expect(error?.messages == ["Resource not found"])
    }

    @Test("throws a typed error even when the body carries no message")
    func throwsTypedErrorWithoutMessage() async throws {
        let error = await #expect(throws: APIError.self) {
            try await intercept(request(.get)) { _, _, _ in
                (HTTPResponse(status: .init(code: 503)), nil)
            }
        }

        #expect(error?.kind == .serverError)
        #expect(error?.messages.isEmpty == true)
    }

    @Test("reports an unknown outcome when a mutating request gets no response", arguments: [
        HTTPRequest.Method.post,
        .put,
        .patch,
        .delete,
    ])
    func reportsUnknownOutcomeForMutatingRequests(method: HTTPRequest.Method) async throws {
        let error = await #expect(throws: APIError.self) {
            try await intercept(request(method)) { _, _, _ in
                throw URLError(.timedOut)
            }
        }

        #expect(error?.kind == .unknownOutcome)
        #expect(error?.status == nil)
    }

    @Test("reports an unknown outcome however the transport failure arrives wrapped")
    func reportsUnknownOutcomeForWrappedFailure() async throws {
        let error = await #expect(throws: APIError.self) {
            try await intercept(request(.post)) { _, _, _ in
                throw ClientError(
                    operationID: "test",
                    operationInput: "input",
                    causeDescription: "transport failed",
                    underlyingError: URLError(.networkConnectionLost)
                )
            }
        }

        #expect(error?.kind == .unknownOutcome)
    }

    @Test("leaves a failed read alone, since nothing can have changed")
    func rethrowsForReads() async throws {
        await #expect(throws: URLError(.timedOut)) {
            try await intercept(request(.get)) { _, _, _ in
                throw URLError(.timedOut)
            }
        }
    }

    // MARK: Private

    private func request(_ method: HTTPRequest.Method) -> HTTPRequest {
        HTTPRequest(method: method, scheme: "https", authority: "api.example.com", path: "/test")
    }

    private func intercept(
        _ request: HTTPRequest,
        next: @escaping (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        try await APIErrorMiddleware().intercept(
            request,
            body: nil,
            baseURL: try #require(URL(string: "https://api.example.com")),
            operationID: "test",
            next: next
        )
    }

}
