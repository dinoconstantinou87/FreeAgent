import ArgumentParser
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import FreeAgentAPI

public protocol ClientCommand: AsyncParsableCommand {
    func run(client: Client) async throws -> OpenAPIRuntime.OpenAPIObjectContainer?
}

extension ClientCommand {
    public func run() async throws {
        let config: CLIConfig
        do {
            config = try CLIConfig.load()
        } catch {
            print("❌ No credentials configured")
            print("Run 'freeagent auth login' to authenticate")
            throw ExitCode.failure
        }
        
        guard let token = try OAuthTokenStorage().load() else {
            print("❌ Not authenticated")
            print("Run 'freeagent auth login' to authenticate")
            throw ExitCode.failure
        }
        
        let environment = token.environment
        let oauthClient = OAuthClient(config: config.oauthConfig, environment: environment)
        
        guard try oauthClient.isAuthenticated() else {
            print("❌ Not authenticated")
            print("Run 'freeagent auth login' to authenticate")
            throw ExitCode.failure
        }
        
        let serverURL = environment.baseURL
        let transport = URLSessionTransport()
        let client = Client(
            serverURL: serverURL,
            transport: transport,
            middlewares: [.oauth(client: oauthClient, config: config.oauthConfig, environment: environment)]
        )
        
        do {
            guard let result = try await run(client: client) else {
                print("❌ Unexpected response from API")
                throw ExitCode.failure
            }
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(result)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "{}"
            print(jsonString)
            
        } catch {
            // Check if error contains validation messages
            let errorString = String(describing: error)
            if errorString.contains("unprocessableContent") && errorString.contains("ErrorResponse") {
                // Extract error messages from the error description
                if let match = errorString.range(of: "errors: [") {
                    let remaining = errorString[match.upperBound...]
                    let messages = remaining.components(separatedBy: "message: \"")
                        .dropFirst()
                        .compactMap { component -> String? in
                            if let endQuote = component.firstIndex(of: "\"") {
                                return String(component[..<endQuote])
                            }
                            return nil
                        }
                    
                    for message in messages {
                        print("❌ \(message)")
                    }
                } else {
                    print("❌ Validation error occurred")
                }
                throw ExitCode.failure
            }
            
            print("❌ Failed to execute command: \(error)")
            throw ExitCode.failure
        }
    }
}
