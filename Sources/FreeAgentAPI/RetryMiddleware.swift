import Foundation
import HTTPTypes
import OpenAPIRuntime

// MARK: - RetryMiddleware

public struct RetryMiddleware: ClientMiddleware {

    // MARK: Public

    public typealias Sleep = @Sendable (Duration) async throws -> Void
    public typealias WillRetry = @Sendable (Duration) -> Void

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID _: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var retries = 0

        while true {
            let (response, responseBody) = try await next(request, body, baseURL)

            guard
                retries < maximumRetries,
                body?.iterationBehavior != .single,
                let delay = Self.delay(honouring: response)
            else {
                return (response, responseBody)
            }

            retries += 1
            willRetry(delay)
            try await sleep(delay)
        }
    }

    // MARK: Internal

    static let maximumDelay = Duration.seconds(60)

    let maximumRetries: Int
    let sleep: Sleep
    let willRetry: WillRetry

    // MARK: Private

    private static func delay(honouring response: HTTPResponse) -> Duration? {
        guard
            response.status == .tooManyRequests,
            let seconds = response.headerFields[.retryAfter].flatMap(Int.init),
            seconds >= 0
        else {
            return nil
        }

        let delay = Duration.seconds(seconds)

        return delay <= maximumDelay ? delay : nil
    }
}

extension ClientMiddleware where Self == RetryMiddleware {
    public static func retry(
        maximumRetries: Int = 3,
        sleep: @escaping RetryMiddleware.Sleep = { try await Task.sleep(for: $0) },
        willRetry: @escaping RetryMiddleware.WillRetry = { _ in }
    ) -> RetryMiddleware {
        RetryMiddleware(maximumRetries: maximumRetries, sleep: sleep, willRetry: willRetry)
    }
}
