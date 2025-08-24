import ArgumentParser
import FreeAgentAPI
import Foundation
#if canImport(AppKit)
import AppKit
#endif

struct LoginCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "login",
        abstract: "Authenticate with FreeAgent API"
    )
    
    @Option(name: .shortAndLong, help: "API environment to use")
    var environment: OAuthFlow.Environment = .sandbox
    
    @Option(name: .shortAndLong, help: "Port for OAuth callback server")
    var port: Int = 8080
    
    @Flag(name: .long, help: "Manual mode - paste the callback URL instead of automatic capture")
    var manual: Bool = false
    
    mutating func run() async throws {
        let config: OAuthConfig
        do {
            config = try OAuthConfig.load()
        } catch {
            print("Error: \(error.localizedDescription)")
            print("\nTo set up credentials, either:")
            print("1. Set environment variables:")
            print("   export FREEAGENT_CLIENT_ID=your_client_id")
            print("   export FREEAGENT_CLIENT_SECRET=your_client_secret")
            print("\n2. Create ~/.freeagent/config.json with:")
            print("   {")
            print("     \"client_id\": \"your_client_id\",")
            print("     \"client_secret\": \"your_client_secret\",")
            print("     \"redirect_uri\": \"http://localhost:\(port)/callback\"")
            print("   }")
            throw ExitCode.failure
        }
        
        let client = OAuthClient(config: config, environment: environment)
        
        if try client.isAuthenticated() {
            print("Already authenticated. Use 'freeagent auth status' to check token status.")
            return
        }
        
        let state = UUID().uuidString
        let authURL = client.authorizationURL(state: state)
        
        print("Opening browser for authentication...")
        print("Authorization URL: \(authURL.absoluteString)\n")
        
        #if canImport(AppKit)
        NSWorkspace.shared.open(authURL)
        #else
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xdg-open")
        process.arguments = [authURL.absoluteString]
        try? process.run()
        #endif
        
        let code: String
        
        if manual {
            print("After authorizing, copy the entire callback URL and paste it here:")
            print("(It should look like: http://localhost:\(port)/callback?code=...)")
            print("")
            
            guard let callbackURL = readLine() else {
                print("Error: No input received")
                throw ExitCode.failure
            }
            
            guard let url = URL(string: callbackURL),
                  let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                print("❌ Error: Invalid callback URL.")
                throw ExitCode.failure
            }
            
            if let error = components.queryItems?.first(where: { $0.name == "error" })?.value {
                let description = components.queryItems?.first(where: { $0.name == "error_description" })?.value ?? ""
                print("❌ Authentication failed: \(error) - \(description)")
                throw ExitCode.failure
            }
            
            guard let extractedCode = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                
                print("❌ Error: Invalid callback URL. Could not extract authorization code.")
                throw ExitCode.failure
            }
            
            if let returnedState = components.queryItems?.first(where: { $0.name == "state" })?.value,
               returnedState != state {
                print("❌ Error: State mismatch. Possible CSRF attack.")
                throw ExitCode.failure
            }
            
            code = extractedCode
        } else {
            print("Starting local server on port \(port)...")
            print("Waiting for callback...")
            print("\nIf the callback doesn't work, run with --manual flag to paste the URL manually.\n")
            
            let serverCode = try await waitForCallback(port: port, expectedState: state)
            code = serverCode
        }
        
        print("Exchanging authorization code for tokens...")
        do {
            let token = try await client.authenticate(code: code)
            print("✅ Authentication successful!")
            print("Token expires in \(Int(token.timeUntilExpiration / 60)) minutes")
        } catch {
            print("❌ Authentication failed: \(error.localizedDescription)")
            throw ExitCode.failure
        }
    }
    
    private func waitForCallback(port: Int, expectedState: String) async throws -> String {
        let server = OAuthCallbackServer(port: port)
        return try await server.waitForOAuthCallback(expectedState: expectedState)
    }
}

extension OAuthFlow.Environment: ExpressibleByArgument {
    public init?(argument: String) {
        switch argument.lowercased() {
        case "production", "prod":
            self = .production
        case "sandbox", "sand":
            self = .sandbox
        default:
            return nil
        }
    }
}
