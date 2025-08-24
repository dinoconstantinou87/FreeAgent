import ArgumentParser
import FreeAgentAPI
import Foundation

struct LogoutCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "logout",
        abstract: "Remove stored authentication tokens"
    )
    
    mutating func run() async throws {
        let config: OAuthConfig
        do {
            config = try OAuthConfig.load()
        } catch {
            print("No credentials configured")
            return
        }
        
        let client = OAuthClient(config: config)
        
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