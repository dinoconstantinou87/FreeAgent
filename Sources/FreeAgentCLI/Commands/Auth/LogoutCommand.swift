import ArgumentParser
import FreeAgentAPI
import Foundation

struct LogoutCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "logout",
        abstract: "Remove stored authentication tokens"
    )
    
    mutating func run() async throws {
        let config: CLIConfig
        do {
            config = try CLIConfig.load()
        } catch {
            print("No credentials configured")
            return
        }
        
        guard let token = try OAuthTokenStorage().load() else {
            print("Not currently authenticated")
            return
        }
        
        let client = OAuthClient(config: config.oauthConfig, environment: token.environment)
        
        let status = try client.authenticationStatus()
        
        switch status {
        case .notAuthenticated:
            print("Not currently authenticated")
            return
            
        case .authenticated, .expired:
            try client.logout()
            print("✅ Logged out successfully")
            print("Tokens have been removed from keychain")
        }
    }
}