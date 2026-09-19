import ArgumentParser
import FreeAgentAPI
import Noora
import OpenAPIRuntime

// MARK: - CommandFailure

struct CommandFailure: Equatable {

    // MARK: Lifecycle

    init(_ error: any Error) {
        guard let cause = APIError.from(error) else {
            alert = .alert("Failed to execute command: \(Self.cause(of: error))")
            exitCode = .failure
            return
        }

        alert = .alert(
            TerminalText(stringLiteral: Self.summary(of: cause)),
            takeaways: Self.takeaways(of: cause)
        )
        exitCode = cause.kind.exitCode
    }

    // MARK: Internal

    let alert: ErrorAlert
    let exitCode: ExitCode

    // MARK: Private

    private static func cause(of error: any Error) -> any Error {
        guard let error = error as? ClientError else { return error }

        return cause(of: error.underlyingError)
    }

    private static func summary(of error: APIError) -> String {
        var summary = error.kind.summary

        if let status = error.status {
            summary += " (HTTP \(status))"
        }

        if error.messages.count == 1, let message = error.messages.first {
            summary += ": \(message)"
        }

        return summary
    }

    private static func takeaways(of error: APIError) -> [TerminalText] {
        guard error.messages.count > 1 else { return error.kind.takeaways }

        return error.messages.map { TerminalText(stringLiteral: $0) } + error.kind.takeaways
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
