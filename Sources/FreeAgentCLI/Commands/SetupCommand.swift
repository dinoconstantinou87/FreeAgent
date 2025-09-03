import ArgumentParser
import FreeAgentAPI
import Foundation
import Noora

struct SetupCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "setup",
        abstract: "Set up the FreeAgent CLI"
    )
    
    mutating func run() async throws {
        let key = Noora().textPrompt(
            title: "FreeAgent app OAuth ID",
            prompt: "What is your FreeAgent app OAuth ID?",
            collapseOnAnswer: true,
            validationRules: [NonEmptyValidationRule(error: "OAuth ID cannot be empty.")]
        )

        let secret = Noora().textPrompt(
            title: "FreeAgent app OAuth secret",
            prompt: "What is your FreeAgent app OAuth secret?",
            collapseOnAnswer: true,
            validationRules: [NonEmptyValidationRule(error: "OAuth secret cannot be empty.")]
        )

        let callbackUrl = Noora().textPrompt(
            title: "FreeAgent app OAuth callbackUrl",
            prompt: "What is your FreeAgent app OAuth redirect URI?",
            collapseOnAnswer: true,
            validationRules: [URLValidationRule(error: "OAuth redirect URI must be a valid URL.")]
        )

        let config = Config(
            auth: .init(
                key: key,
                secret: secret,
                callbackUrl: URL(string: callbackUrl)!
            )
        )

        try config.save()

        Noora().success(.alert("FreeAgent CLI successfully setup"))
    }
}
