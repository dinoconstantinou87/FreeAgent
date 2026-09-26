import ArgumentParser
import FreeAgentAPI
import Noora

// MARK: - APIError + CommandError

extension APIError: CommandError {

    // MARK: Public

    public var errorDescription: String? {
        var summary = kind.summary

        if let status {
            summary += " (HTTP \(status))"
        }

        if messages.count == 1, let message = messages.first {
            summary += ": \(message)"
        }

        return summary
    }

    // MARK: Internal

    var exitCode: ExitCode {
        kind.exitCode
    }

    var takeaways: [TerminalText] {
        guard messages.count > 1 else { return kind.takeaways }

        return messages.map { TerminalText(stringLiteral: $0) } + kind.takeaways
    }
}

extension APIError.Kind {

    var exitCode: ExitCode {
        switch self {
        case .unauthenticated: ExitCode(2)
        case .notFound: ExitCode(3)
        case .rejected: ExitCode(4)
        case .forbidden: ExitCode(5)
        case .rateLimited: ExitCode(6)
        case .serverError: ExitCode(7)
        case .unknownOutcome: ExitCode(8)
        case .unexpected: .failure
        }
    }

    var summary: String {
        switch self {
        case .unauthenticated: "Not authenticated with FreeAgent"
        case .forbidden: "Your FreeAgent user is not allowed to do that"
        case .notFound: "FreeAgent has no such record"
        case .rejected: "FreeAgent rejected the request"
        case .rateLimited: "FreeAgent rate limit reached"
        case .serverError: "FreeAgent failed to handle the request"
        case .unknownOutcome: "FreeAgent did not respond, so it is unknown whether the change was applied"
        case .unexpected: "FreeAgent returned an unexpected response"
        }
    }

    var takeaways: [TerminalText] {
        switch self {
        case .unauthenticated: ["Run \(.command("freeagent auth login"))"]
        case .rateLimited: ["Wait before retrying"]
        case .serverError: ["Retry - this is a fault on FreeAgent's side"]
        case .unknownOutcome: ["Check FreeAgent before retrying, so the change is not applied twice"]
        default: []
        }
    }
}
