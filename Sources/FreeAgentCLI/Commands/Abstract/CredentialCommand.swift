import ArgumentParser
import Noora

// MARK: - CredentialCommand

protocol CredentialCommand: AsyncParsableCommand {
    associatedtype Outcome

    func perform() async throws -> Outcome
    func success(for outcome: Outcome) -> String
}

extension CredentialCommand {
    func run() async throws {
        do {
            let outcome = try await perform()
            Noora().success(.alert(TerminalText(stringLiteral: success(for: outcome))))
        } catch {
            let failure = error.commandError
            Noora().error(failure.alert)
            throw failure.exitCode
        }
    }
}
