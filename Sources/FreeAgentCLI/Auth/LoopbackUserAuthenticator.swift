import FlyingFox
import Foundation
import FreeAgentAPI
import Noora
import OAuthenticator

struct LoopbackUserAuthenticator: Sendable {

    // MARK: Lifecycle

    init(callbackUrl: URL) {
        self.init(callbackUrl: callbackUrl, openUrl: Self.open, ui: Noora.standardError())
    }

    init(callbackUrl: URL, openUrl: @escaping OpenUrl, ui: any Noorable) {
        self.callbackUrl = callbackUrl
        self.openUrl = openUrl
        self.ui = ui
    }

    // MARK: Internal

    typealias OpenUrl = @Sendable (URL) throws -> Void

    var userAuthenticator: AuthClient.UserAuthenticator {
        { [callbackUrl, openUrl, ui] authorizationUrl, _ in
            try await Self.authenticate(
                callbackUrl: callbackUrl,
                authorizationUrl: authorizationUrl,
                openUrl: openUrl,
                ui: ui
            )
        }
    }

    // MARK: Private

    private static let completionMessage =
        "Authentication Complete - You can close this window and return to the terminal"

    private let callbackUrl: URL
    private let openUrl: OpenUrl
    private let ui: any Noorable

    private static func open(_ url: URL) throws {
        let process = Process()
        #if os(macOS)
        process.executableURL = URL(filePath: "/usr/bin/open")
        #else
        process.executableURL = URL(filePath: "/usr/bin/xdg-open")
        #endif
        process.arguments = [url.absoluteString]

        try process.run()
    }

    private static func authenticate(
        callbackUrl: URL,
        authorizationUrl: URL,
        openUrl: @escaping OpenUrl,
        ui: any Noorable
    ) async throws -> URL {
        let server = HTTPServer(port: UInt16(callbackUrl.port ?? 80), logger: .disabled)
        let redirects = AsyncStream<URL>.makeStream()

        await server.appendRoute(HTTPRoute(callbackUrl.path())) { request in
            var components = URLComponents()
            components.path = request.path
            components.queryItems = request.query.map { item in
                URLQueryItem(name: item.name, value: item.value)
            }

            guard let url = components.url else {
                return HTTPResponse(statusCode: .badRequest, body: Data("Authentication Failed".utf8))
            }

            redirects.continuation.yield(url)

            return HTTPResponse(
                statusCode: .ok,
                headers: [.contentType: "text/plain; charset=utf-8"],
                body: Data(completionMessage.utf8)
            )
        }

        return try await withThrowingTaskGroup(of: URL.self) { group in
            group.addTask {
                try await server.run()
                throw AuthenticatorError.missingAuthorizationCode
            }

            group.addTask {
                try await server.waitUntilListening()
                try openUrl(authorizationUrl)
                ui.info(.alert(
                    "Waiting for you to log in to FreeAgent in your browser",
                    takeaways: ["If it did not open, visit \(authorizationUrl.absoluteString)"]
                ))

                for await url in redirects.stream {
                    return url
                }

                throw AuthenticatorError.missingAuthorizationCode
            }

            guard let url = try await group.next() else {
                throw AuthenticatorError.missingAuthorizationCode
            }

            await server.stop()

            return url
        }
    }

}
