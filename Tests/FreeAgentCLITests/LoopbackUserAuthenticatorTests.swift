import Foundation
import OAuthenticator
import Swifter
import Synchronization
import Testing

@testable import FreeAgentCLI

// MARK: - LoopbackUserAuthenticatorTests

struct LoopbackUserAuthenticatorTests {

    // MARK: Internal

    @Test("returns the redirect url the browser was sent to")
    func returnsRedirectUrl() async throws {
        let port = try Self.freePort()
        let callbackUrl = try #require(URL(string: "http://localhost:\(port)/callback"))

        let authenticator = LoopbackUserAuthenticator(callbackUrl: callbackUrl) { _ in
            Task {
                try await Self.get("http://localhost:\(port)/callback?code=the-code&state=the-state")
            }
        }

        let redirect = try await authenticator.userAuthenticator(Self.authorizationUrl, "http")

        #expect(redirect.queryValues(named: "code").first == "the-code")
        #expect(redirect.queryValues(named: "state").first == "the-state")
    }

    @Test("serves the completion page to the browser before shutting down")
    func servesCompletionPage() async throws {
        let port = try Self.freePort()
        let callbackUrl = try #require(URL(string: "http://localhost:\(port)/callback"))
        let page = Mutex("")

        let authenticator = LoopbackUserAuthenticator(callbackUrl: callbackUrl) { _ in
            Task {
                let body = try await Self.get("http://localhost:\(port)/callback?code=the-code")
                page.withLock { $0 = body }
            }
        }

        _ = try await authenticator.userAuthenticator(Self.authorizationUrl, "http")

        try await Task.sleep(for: .milliseconds(200))

        let body = page.withLock { $0 }
        #expect(body.contains("Authentication Complete"))
    }

    @Test("opens the authorization url it was given")
    func opensAuthorizationUrl() async throws {
        let port = try Self.freePort()
        let callbackUrl = try #require(URL(string: "http://localhost:\(port)/callback"))
        let opened = Mutex<URL?>(nil)

        let authenticator = LoopbackUserAuthenticator(callbackUrl: callbackUrl) { url in
            opened.withLock { $0 = url }
            Task {
                try await Self.get("http://localhost:\(port)/callback?code=the-code")
            }
        }

        _ = try await authenticator.userAuthenticator(Self.authorizationUrl, "http")

        let url = opened.withLock { $0 }
        #expect(url == Self.authorizationUrl)
    }

    @Test("releases the callback port once authentication completes")
    func releasesPort() async throws {
        let port = try Self.freePort()
        let callbackUrl = try #require(URL(string: "http://localhost:\(port)/callback"))

        let authenticator = LoopbackUserAuthenticator(callbackUrl: callbackUrl) { _ in
            Task {
                try await Self.get("http://localhost:\(port)/callback?code=the-code")
            }
        }

        _ = try await authenticator.userAuthenticator(Self.authorizationUrl, "http")

        #expect(throws: Never.self) {
            try Self.bind(port: port)
        }
    }

    // MARK: Private

    private static let authorizationUrl = URL(filePath: "/approve_app")

    private static func freePort() throws -> UInt16 {
        let socket = try Socket.tcpSocketForListen(0)
        let port = try socket.port()
        socket.close()

        return port
    }

    private static func bind(port: UInt16) throws {
        let socket = try Socket.tcpSocketForListen(port)
        socket.close()
    }

    @discardableResult
    private static func get(_ string: String) async throws -> String {
        guard let url = URL(string: string) else {
            return ""
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        return String(decoding: data, as: UTF8.self)
    }

}
