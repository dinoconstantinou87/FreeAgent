import Foundation
import OAuthenticator
import Swifter
import Testing

@testable import FreeAgentCLI

// MARK: - LoopbackUserAuthenticatorTests

struct LoopbackUserAuthenticatorTests {

    // MARK: Internal

    @Test("returns the redirect url the browser was sent to")
    func returnsRedirectUrl() async throws {
        let flow = try await authenticate(query: "code=the-code&state=the-state")

        #expect(flow.redirect.queryValues(named: "code").first == "the-code")
        #expect(flow.redirect.queryValues(named: "state").first == "the-state")
    }

    @Test("opens the authorization url it was given")
    func opensAuthorizationUrl() async throws {
        let flow = try await authenticate()

        #expect(flow.opened == Self.authorizationUrl)
    }

    @Test("serves the completion page to the browser before shutting down")
    func servesCompletionPage() async throws {
        let flow = try await authenticate()

        #expect(flow.page.contains("Authentication Complete"))
    }

    @Test("releases the callback port once authentication completes")
    func releasesPort() async throws {
        let port = try Self.freePort()

        _ = try await authenticate(port: port)

        #expect(throws: Never.self) {
            try Self.bind(port: port)
        }
    }

    // MARK: Private

    private struct Flow {
        let redirect: URL
        let opened: URL
        let page: String
    }

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

    private static func get(_ string: String) async throws -> String {
        guard let url = URL(string: string) else {
            return ""
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        return String(decoding: data, as: UTF8.self)
    }

    private func authenticate(
        port: UInt16? = nil,
        query: String = "code=the-code"
    ) async throws -> Flow {
        let port = try port ?? Self.freePort()
        let callbackUrl = try #require(URL(string: "http://localhost:\(port)/callback"))
        let browser = AsyncStream<URL>.makeStream()

        let authenticator = LoopbackUserAuthenticator(callbackUrl: callbackUrl) { url in
            browser.continuation.yield(url)
        }

        async let redirect = authenticator.userAuthenticator(Self.authorizationUrl, "http")

        var opened = browser.stream.makeAsyncIterator()
        let authorizationUrl = try #require(await opened.next())
        let page = try await Self.get("http://localhost:\(port)/callback?\(query)")

        return Flow(redirect: try await redirect, opened: authorizationUrl, page: page)
    }

}
