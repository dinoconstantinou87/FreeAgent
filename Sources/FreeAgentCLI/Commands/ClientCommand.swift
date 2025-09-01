import ArgumentParser
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import FreeAgentAPI
import Noora

public protocol ClientCommand: AsyncParsableCommand {
    associatedtype Response: Codable
    func run(client: Client) async throws -> Response?
}

extension ClientCommand {
    public func run() async throws {
        guard let credential = try AuthStorage().get() else {
            Noora().error(.alert("Not logged in", takeaways: ["Run \(.command("freeagent auth login"))"]))
            throw ExitCode.failure
        }

        let serverURL = credential.environment.baseURL
        let transport = URLSessionTransport()
        let client = Client(
            serverURL: serverURL,
            transport: transport,
            middlewares: [.auth(credential.token)]
        )
        
        do {
            guard let result = try await run(client: client) else {
                Noora().error(.alert("Unexpected response from API"))
                throw ExitCode.failure
            }

            try Noora().json(result)
        } catch {
            Noora().error(.alert("Failed to execute command: \(error)"))
            throw ExitCode.failure
        }
    }
}
