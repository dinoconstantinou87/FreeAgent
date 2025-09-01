import ArgumentParser
import FreeAgentAPI
import Foundation
import Noora

struct LogoutCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "logout",
        abstract: "Logout"
    )
    
    mutating func run() async throws {
        try AuthStorage().clear()
        Noora().success(.alert("Logged out"))
    }
}
