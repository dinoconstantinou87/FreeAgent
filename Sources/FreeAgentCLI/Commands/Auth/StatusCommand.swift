import ArgumentParser
import FreeAgentAPI
import Foundation

struct StatusCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "status",
        abstract: "Check authentication status"
    )
    
    mutating func run() async throws {
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
            return
        }
        
        let client = OAuthClient(config: config.oauthConfig, environment: token.environment)
        
        let status = try client.authenticationStatus()
        
        switch status {
        case .notAuthenticated:
            print("❌ Not authenticated")
            print("Run 'freeagent auth login' to authenticate")
            
        case .authenticated(let expiresIn):
            print("✅ Authenticated")
            print("Environment: \(token.environment)")
            
            let minutes = Int(expiresIn / 60)
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            
            if hours > 0 {
                print("Token expires in: \(hours)h \(remainingMinutes)m")
            } else if minutes > 0 {
                print("Token expires in: \(minutes) minutes")
            } else {
                print("Token expires: soon (less than 1 minute)")
            }
            
            if let token = try client.currentToken() {
                print("\nToken details:")
                print("  Type: \(token.tokenType)")
                if let scope = token.scope {
                    print("  Scope: \(scope)")
                }
                print("  Issued: \(token.receivedAt.formatted(date: .abbreviated, time: .shortened))")
            }
            
        case .expired:
            print("⚠️  Token expired")
            print("The token has expired but can be refreshed")
            print("Token refresh will happen automatically when making API calls")
        }
    }
}