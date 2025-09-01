import Foundation
@preconcurrency import Swifter
import ServiceLifecycle
import FreeAgentAPI

struct AuthCallbackService: Service {
    let url: URL
    let client: AuthClient

    func run() async throws {
        let stream = AsyncThrowingStream { continuation in
            let server = HttpServer()
            server[url.path()] = { request in
                var components = URLComponents()
                components.path = request.path
                components.queryItems = request.queryParams.map { name, value in
                    URLQueryItem(name: name, value: value)
                }

                if let url = components.url {
                    continuation.yield(url)
                    return .ok(.text("Authentication Complete - You can close this window and return to the terminal"))
                } else {
                    return .badRequest(.text("Authentication Failed"))
                }
            }

            do {
                try server.start(UInt16(url.port ?? 80))
                print("Waiting for login to complete...")
            } catch {
                continuation.yield(with: .failure(error))
            }

            continuation.onTermination = { _ in
                server.stop()
            }
        }

        for try await url in stream {
            client.handle(url: url)
        }
    }
}
