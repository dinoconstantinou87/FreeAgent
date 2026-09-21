import Foundation
import HTTPTypes
import OpenAPIRuntime
import Synchronization
import Testing

@testable import FreeAgentAPI

struct RetryMiddlewareTests {

    // MARK: Internal

    @Test("retries a rate limited response and returns the eventual success")
    func retriesUntilSuccess() async throws {
        let attempts = Mutex(0)

        let (response, _) = try await intercept { _, _, _ in
            let attempt = attempts.withLock { attempts -> Int in
                attempts += 1
                return attempts
            }

            return attempt == 1 ? (rateLimited(retryAfter: "5"), nil) : (HTTPResponse(status: .ok), nil)
        }

        #expect(response.status == .ok)
        #expect(attempts.withLock { $0 } == 2)
    }

    @Test("waits for the duration the header asks for")
    func waitsForTheRequestedDuration() async throws {
        let waits = Mutex([Duration]())

        _ = try await intercept(sleep: { duration in waits.withLock { $0.append(duration) } }) { _, _, _ in
            (rateLimited(retryAfter: "42"), nil)
        }

        #expect(waits.withLock { $0 } == [.seconds(42), .seconds(42), .seconds(42)])
    }

    @Test("reports every wait before sleeping")
    func reportsEveryWait() async throws {
        let reported = Mutex([Duration]())

        _ = try await intercept(
            maximumRetries: 2,
            willRetry: { duration in reported.withLock { $0.append(duration) } }
        ) { _, _, _ in
            (rateLimited(retryAfter: "7"), nil)
        }

        #expect(reported.withLock { $0 } == [.seconds(7), .seconds(7)])
    }

    @Test("gives up after the retry limit and surfaces the rate limited response")
    func givesUpAfterTheRetryLimit() async throws {
        let attempts = Mutex(0)

        let (response, _) = try await intercept { _, _, _ in
            attempts.withLock { $0 += 1 }

            return (rateLimited(retryAfter: "1"), nil)
        }

        #expect(response.status == .tooManyRequests)
        #expect(attempts.withLock { $0 } == 4)
    }

    @Test("does not retry a rate limited response that asks for no particular wait", arguments: [
        String?.none,
        "Wed, 21 Oct 2015 07:28:00 GMT",
        "-1",
    ])
    func doesNotRetryWithoutUsableRetryAfter(header: String?) async throws {
        let attempts = try await attemptsAgainst(rateLimited(retryAfter: header))

        #expect(attempts == 1)
    }

    @Test("does not wait longer than the window the rate limit resets in")
    func doesNotRetryBeyondTheDelayCap() async throws {
        let attempts = try await attemptsAgainst(rateLimited(retryAfter: "61"))

        #expect(attempts == 1)
    }

    @Test("retries a wait that sits exactly on the cap")
    func retriesAtTheDelayCap() async throws {
        let attempts = try await attemptsAgainst(rateLimited(retryAfter: "60"))

        #expect(attempts == 4)
    }

    @Test("passes every other status through untouched", arguments: [
        HTTPResponse.Status.ok,
        .badRequest,
        .internalServerError,
        .serviceUnavailable,
    ])
    func passesOtherStatusesThrough(status: HTTPResponse.Status) async throws {
        var response = HTTPResponse(status: status)
        response.headerFields[.retryAfter] = "5"

        let attempts = try await attemptsAgainst(response)

        #expect(attempts == 1)
    }

    @Test("retries a write whose body can be sent again")
    func retriesAReplayableWrite() async throws {
        let attempts = Mutex(0)

        _ = try await intercept(request(.post), body: HTTPBody(#"{"invoice":{}}"#)) { _, body, _ in
            attempts.withLock { $0 += 1 }
            _ = try await Data(collecting: try #require(body), upTo: .max)

            return (rateLimited(retryAfter: "1"), nil)
        }

        #expect(attempts.withLock { $0 } == 4)
    }

    @Test("does not retry a body that can only be sent once")
    func doesNotRetryASingleUseBody() async throws {
        let body = HTTPBody([UInt8]("{}".utf8), length: .known(2), iterationBehavior: .single)
        let attempts = Mutex(0)

        _ = try await intercept(request(.post), body: body) { _, _, _ in
            attempts.withLock { $0 += 1 }

            return (rateLimited(retryAfter: "1"), nil)
        }

        #expect(attempts.withLock { $0 } == 1)
    }

    // MARK: Private

    private func request(_ method: HTTPRequest.Method = .get) -> HTTPRequest {
        HTTPRequest(method: method, scheme: "https", authority: "api.example.com", path: "/test")
    }

    private func rateLimited(retryAfter: String?) -> HTTPResponse {
        var response = HTTPResponse(status: .tooManyRequests)
        response.headerFields[.retryAfter] = retryAfter

        return response
    }

    private func attemptsAgainst(_ response: HTTPResponse) async throws -> Int {
        let attempts = Mutex(0)

        _ = try await intercept { _, _, _ in
            attempts.withLock { $0 += 1 }

            return (response, nil)
        }

        return attempts.withLock { $0 }
    }

    private func intercept(
        _ request: HTTPRequest? = nil,
        body: HTTPBody? = nil,
        maximumRetries: Int = 3,
        sleep: @escaping RetryMiddleware.Sleep = { _ in },
        willRetry: @escaping RetryMiddleware.WillRetry = { _ in },
        next: @escaping (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        try await RetryMiddleware(maximumRetries: maximumRetries, sleep: sleep, willRetry: willRetry).intercept(
            request ?? self.request(),
            body: body,
            baseURL: try #require(URL(string: "https://api.example.com")),
            operationID: "test",
            next: next
        )
    }

}
