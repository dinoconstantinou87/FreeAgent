import Foundation
import FreeAgentAPI
import Logging
import OAuthenticator
@preconcurrency import Swifter

struct LoopbackUserAuthenticator: Sendable {

    // MARK: Lifecycle

    init(callbackUrl: URL) {
        self.init(callbackUrl: callbackUrl, openUrl: Self.open)
    }

    init(callbackUrl: URL, openUrl: @escaping OpenUrl) {
        self.callbackUrl = callbackUrl
        self.openUrl = openUrl
    }

    // MARK: Internal

    typealias OpenUrl = @Sendable (URL) throws -> Void

    var userAuthenticator: AuthClient.UserAuthenticator {
        { [callbackUrl, openUrl] authorizationUrl, _ in
            try await Self.authenticate(
                callbackUrl: callbackUrl,
                authorizationUrl: authorizationUrl,
                openUrl: openUrl
            )
        }
    }

    // MARK: Private

    private static let logger = Logger(label: "oauth-callback")

    private static let completionMessage =
        "Authentication Complete - You can close this window and return to the terminal"

    private let callbackUrl: URL
    private let openUrl: OpenUrl

    private static func open(_ url: URL) throws {
        let process = Process()
        process.executableURL = URL(filePath: "/usr/bin/open")
        process.arguments = [url.absoluteString]

        try process.run()
    }

    private static func authenticate(
        callbackUrl: URL,
        authorizationUrl: URL,
        openUrl: OpenUrl
    ) async throws -> URL {
        let server = HttpServer()
        let redirects = AsyncStream<URL>.makeStream()

        server[callbackUrl.path()] = { request in
            var components = URLComponents()
            components.path = request.path
            components.queryItems = request.queryParams.map { name, value in
                URLQueryItem(name: name, value: value)
            }

            guard let url = components.url else {
                return .badRequest(.text("Authentication Failed"))
            }

            return .raw(200, "OK", ["Content-Type": "text/plain; charset=utf-8"]) { writer in
                try writer.write(Data(completionMessage.utf8))

                redirects.continuation.yield(url)
            }
        }

        try server.start(UInt16(callbackUrl.port ?? 80))

        defer {
            server.stop()
        }

        try openUrl(authorizationUrl)
        logger.info("Waiting for login to complete...")

        for await url in redirects.stream {
            return url
        }

        throw AuthenticatorError.missingAuthorizationCode
    }

}
